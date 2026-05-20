param(
    [string]$Version = "3.2.4"
)

$olderVersions = @(
    "1.5.0", "1.5.1", "1.5.2", "1.5.3", "1.5.4", "1.5.5", "1.5.6", "1.5.7",
    "2.0.0", "2.0.1", "2.0.3",
    "2.1.0", "2.1.2",
    "2.3.0", "2.3.1", "2.3.2", "2.3.3", "2.3.4", "2.3.5", "2.3.6", "2.3.7",
    "2.3.8", "2.3.9", "2.3.10", "2.3.11", "2.3.12", "2.3.13", "2.3.14", "2.3.15",
    "3.0.0", "3.0.1",
    "3.1.0", "3.1.1", "3.1.2", "3.1.3", "3.1.4", "3.1.5", "3.1.6", "3.1.7", "3.1.8",
    "3.2.0", "3.2.1", "3.2.2", "3.2.3"
)

$upgradeDir = Join-Path $PSScriptRoot "..\..\upgrade"
New-Item -ItemType Directory -Force -Path $upgradeDir | Out-Null

foreach ($v in $olderVersions) {
    $outFile = Join-Path $upgradeDir "plv8--${v}--${Version}.sql"
    @"
CREATE OR REPLACE FUNCTION plv8_version ( )
RETURNS TEXT AS
`$`$
    return "$Version";
`$`$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION plv8_call_handler() RETURNS language_handler
 AS 'MODULE_PATHNAME' LANGUAGE C;
CREATE OR REPLACE FUNCTION plv8_inline_handler(internal) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;
CREATE OR REPLACE FUNCTION plv8_call_validator(oid) RETURNS void
 AS 'MODULE_PATHNAME' LANGUAGE C;
"@ | Set-Content -Path $outFile -Encoding UTF8
}

Write-Host "Generated $($olderVersions.Count) upgrade files in $upgradeDir"
