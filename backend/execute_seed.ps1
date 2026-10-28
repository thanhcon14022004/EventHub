$sqlPath = "d:\Ki8\PRM393\EventHub\docs\database\seed_users.sql"
if (-not (Test-Path $sqlPath)) {
    Write-Error "Khong tim thay file SQL: $sqlPath"
    exit 1
}

$sqlContent = Get-Content -Raw -Encoding UTF8 $sqlPath

$servers = @(".\SQLEXPRESS", "localhost", "(localdb)\MSSQLLocalDB", ".")

$connected = $false
$targetServer = ""

foreach ($srv in $servers) {
    Write-Host "Dang thu ket noi toi SQL Server: $srv ..."
    try {
        $connStr = "Server=$srv;Database=master;Trusted_Connection=True;TrustServerCertificate=True;Connect Timeout=3;"
        $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
        $conn.Open()
        Write-Host ">>> Ket noi thanh cong toi $srv!" -ForegroundColor Green
        $targetServer = $srv
        $conn.Close()
        $connected = $true
        break
    } catch {
        Write-Host "Khong the ket noi toi $($srv): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if (-not $connected) {
    Write-Error "Khong the ket noi toi bat ky instance SQL Server nao! Vui long kiem tra xem SQL Server service da duoc Start chua."
    exit 1
}

# 1. Kiem tra xem database EventHubDb da ton tai chua, neu chua thi tao
Write-Host "Kiem tra database EventHubDb tren $targetServer ..."
$masterConnStr = "Server=$targetServer;Database=master;Trusted_Connection=True;TrustServerCertificate=True;"
$masterConn = New-Object System.Data.SqlClient.SqlConnection($masterConnStr)
$masterConn.Open()
$cmdCreateDb = $masterConn.CreateCommand()
$cmdCreateDb.CommandText = "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'EventHubDb') BEGIN CREATE DATABASE EventHubDb; END"
$cmdCreateDb.ExecuteNonQuery()
$masterConn.Close()
Write-Host "Database EventHubDb san sang!" -ForegroundColor Green

# 2. Dam bao bang Users da ton tai
$dbConnStr = "Server=$targetServer;Database=EventHubDb;Trusted_Connection=True;TrustServerCertificate=True;"
$dbConn = New-Object System.Data.SqlClient.SqlConnection($dbConnStr)
$dbConn.Open()

$createTableSql = @"
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        FullName NVARCHAR(255) NOT NULL,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        Password NVARCHAR(255) NOT NULL DEFAULT '1234567',
        PhoneNumber NVARCHAR(20) NULL,
        AvatarUrl NVARCHAR(500) NULL,
        UserRole NVARCHAR(50) NOT NULL DEFAULT 'Customer',
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
"@

$cmdTable = $dbConn.CreateCommand()
$cmdTable.CommandText = $createTableSql
$cmdTable.ExecuteNonQuery()

# 3. Chay cac block trong seed_users.sql (tach boi GO)
$blocks = [System.Text.RegularExpressions.Regex]::Split($sqlContent, "^\s*GO\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

foreach ($block in $blocks) {
    $trimmed = $block.Trim()
    if ($trimmed.Length -gt 0) {
        # Bo qua lenh USE vi da ket noi truc tiep vao EventHubDb
        if ($trimmed -match "^\s*USE\s+EventHubDb" -and $trimmed.Length -lt 25) {
            continue
        }
        try {
            $cmd = $dbConn.CreateCommand()
            $cmd.CommandText = $trimmed
            $cmd.ExecuteNonQuery() | Out-Null
        } catch {
            Write-Host "Warning khi chay block: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# 4. Lay ket qua kiem tra
$cmdCount = $dbConn.CreateCommand()
$cmdCount.CommandText = "SELECT COUNT(*) FROM Users"
$totalUsers = $cmdCount.ExecuteScalar()

$cmdSelect = $dbConn.CreateCommand()
$cmdSelect.CommandText = "SELECT FullName, Email, UserRole, PhoneNumber FROM Users ORDER BY CreatedAt ASC"
$reader = $cmdSelect.ExecuteReader()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "DA CHEN THANH CONG! TONG SO USERS TRONG DATABASE: $totalUsers" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

while ($reader.Read()) {
    $role = $reader["UserRole"]
    $name = $reader["FullName"]
    $email = $reader["Email"]
    $phone = $reader["PhoneNumber"]
    Write-Host "[$role] $name | $email | $phone"
}
$reader.Close()
$dbConn.Close()
