param([string]$PgVersion)
$f = "C:\Program Files\PostgreSQL\$PgVersion\include\server\port\atomics\generic-msvc.h"
$c = [System.IO.File]::ReadAllText($f)

# MSVC 2019 rejects implicit volatile uint32* -> volatile LONG* (32-bit ops)
# and volatile uint64* -> volatile LONGLONG* (64-bit ops).
# Cast &ptr->value to the correct signed pointer type for each intrinsic.
$c = $c -replace 'InterlockedCompareExchange\(&ptr->value,', 'InterlockedCompareExchange((volatile LONG *)&ptr->value,'
$c = $c -replace 'InterlockedExchange\(&ptr->value,', 'InterlockedExchange((volatile LONG *)&ptr->value,'
$c = $c -replace 'InterlockedExchangeAdd\(&ptr->value,', 'InterlockedExchangeAdd((volatile LONG *)&ptr->value,'
$c = $c -replace '_InterlockedCompareExchange64\(&ptr->value,', '_InterlockedCompareExchange64((volatile LONGLONG *)&ptr->value,'
$c = $c -replace '_InterlockedExchange64\(&ptr->value,', '_InterlockedExchange64((volatile LONGLONG *)&ptr->value,'
$c = $c -replace '_InterlockedExchangeAdd64\(&ptr->value,', '_InterlockedExchangeAdd64((volatile LONGLONG *)&ptr->value,'

[System.IO.File]::WriteAllText($f, $c)
Write-Host "Patched $f"
