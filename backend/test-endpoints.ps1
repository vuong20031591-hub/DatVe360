# Test all API endpoints
$baseUrl = "http://localhost:5000"

Write-Host "`n=== TESTING API ENDPOINTS ===`n" -ForegroundColor Cyan

# Test endpoints (GET only - no auth required)
$endpoints = @(
    # System
    @{ Method="GET"; Path="/health"; Name="Health Check" },

    # Destinations (3)
    @{ Method="GET"; Path="/api/v1/destinations"; Name="All Destinations" },
    @{ Method="GET"; Path="/api/v1/destinations/popular"; Name="Popular Destinations" },
    @{ Method="GET"; Path="/api/v1/destinations/search?q=ha"; Name="Search Destinations" },

    # Trips (3)
    @{ Method="GET"; Path="/api/v1/trips/popular-routes"; Name="Popular Routes" },
    @{ Method="GET"; Path="/api/v1/trips/schedules/HAN/SGN"; Name="Trip Schedules" },
    @{ Method="GET"; Path="/api/v1/trips/carriers/HAN/SGN"; Name="Trip Carriers" },

    # Schedules (2)
    @{ Method="GET"; Path="/api/v1/schedules/delayed"; Name="Delayed Schedules" },
    @{ Method="GET"; Path="/api/v1/schedules/search?from=HAN&to=SGN&departureDate=2025-10-10&mode=flight"; Name="Search Schedules" },

    # Payments (2)
    @{ Method="GET"; Path="/api/v1/payments/banks"; Name="Payment Banks" },
    @{ Method="GET"; Path="/api/v1/payments/vnpay/test"; Name="VNPay Test" }
)

$successCount = 0
$failCount = 0

foreach ($endpoint in $endpoints) {
    $url = "$baseUrl$($endpoint.Path)"
    Write-Host "Testing: $($endpoint.Name)" -NoNewline

    try {
        $response = Invoke-RestMethod -Uri $url -Method $endpoint.Method -TimeoutSec 5 -ErrorAction Stop
        Write-Host " - " -NoNewline
        Write-Host "OK" -ForegroundColor Green
        $successCount++

        # Show data count if available
        if ($response.data) {
            $count = if ($response.data -is [Array]) { $response.data.Count } else { 1 }
            Write-Host "  Data items: $count" -ForegroundColor Yellow
        }
    } catch {
        Write-Host " - " -NoNewline
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host "Total: $($successCount + $failCount)" -ForegroundColor Yellow

