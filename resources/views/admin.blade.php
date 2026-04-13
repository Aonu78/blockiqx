@extends('layouts.app')

@section('content')
<div class="container-fluid py-4">
    <div class="row">
        {{-- Row 1: Summary Cards --}}
        <div class="col-xl-3 col-sm-6 mb-xl-0 mb-4">
            <div class="card">
                <div class="card-body p-3">
                    <div class="row">
                        <div class="col-8">
                            <div class="numbers">
                                <p class="text-sm mb-0 text-capitalize font-weight-bold">Total Reports</p>
                                <h5 class="font-weight-bolder mb-0">
                                    {{ \App\Models\Report::count() }}
                                </h5>
                            </div>
                        </div>
                        <div class="col-4 text-end">
                            <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                <i class="bi bi-collection text-lg opacity-10" aria-hidden="true"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-sm-6 mb-xl-0 mb-4">
            <div class="card">
                <div class="card-body p-3">
                    <div class="row">
                        <div class="col-8">
                            <div class="numbers">
                                <p class="text-sm mb-0 text-capitalize font-weight-bold">Total Users</p>
                                <h5 class="font-weight-bolder mb-0">
                                    {{ \App\Models\User::count() }}
                                </h5>
                            </div>
                        </div>
                        <div class="col-4 text-end">
                            <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                <i class="bi bi-globe text-lg opacity-10" aria-hidden="true"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-sm-6 mb-xl-0 mb-4">
            <div class="card">
                <div class="card-body p-3">
                    <div class="row">
                        <div class="col-8">
                            <div class="numbers">
                                <p class="text-sm mb-0 text-capitalize font-weight-bold">Total Staff</p>
                                <h5 class="font-weight-bolder mb-0">
                                    {{ \App\Models\Staff::count() }}
                                </h5>
                            </div>
                        </div>
                        <div class="col-4 text-end">
                            <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                <i class="bi bi-award text-lg opacity-10" aria-hidden="true"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-sm-6">
            <div class="card">
                <div class="card-body p-3">
                    <div class="row">
                        <div class="col-8">
                            <div class="numbers">
                                <p class="text-sm mb-0 text-capitalize font-weight-bold">Pending Reports</p>
                                <h5 class="font-weight-bolder mb-0">
                                    {{ \App\Models\Report::where('status', 'Pending')->count() }}
                                </h5>
                            </div>
                        </div>
                        <div class="col-4 text-end">
                            <div class="icon icon-shape bg-gradient-primary shadow text-center border-radius-md">
                                <i class="bi bi-cart text-lg opacity-10" aria-hidden="true"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Row 2: Charts Section --}}
    <div class="row mt-4">
        <div class="col-lg-6 mb-lg-0 mb-4">
            <div class="card z-index-2">
                <div class="card-header pb-0 pt-3 bg-transparent">
                    <h6>Reports by Status</h6>
                </div>
                <div class="card-body p-3">
                    <div class="chart">
                        <canvas id="reportsByStatusChart" class="chart-canvas" height="250"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-6 mb-lg-0 mb-4">
            <div class="card z-index-2">
                <div class="card-header pb-0 pt-3 bg-transparent">
                    <h6>Reports by Incident Type</h6>
                </div>
                <div class="card-body p-3">
                    <div class="chart">
                        <canvas id="reportsByTypeChart" class="chart-canvas" height="250"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Row 3: Area Insights Chart --}}
    <div class="row mt-4">
        <div class="col-lg-12 mb-lg-0 mb-4">
            <div class="card z-index-2">
                <div class="card-header pb-0 pt-3 bg-transparent">
                    <h6>Reports by Area</h6>
                </div>
                <div class="card-body p-3">
                    <div class="chart">
                        <canvas id="reportsByAreaChart" class="chart-canvas" height="200"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


{{-- Inline Styles for the dashboard design --}}
<style>
.card-blog {
    transition: all 0.3s ease;
    cursor: pointer;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    border: none; /* Remove default card border if any */
}
.card-blog:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.15);
}
.card-blog .icon {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 50px;
    height: 50px;
    margin-top: -25px; /* Adjust to lift icon slightly above card */
    border-radius: 50%;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}
.card-blog .icon i {
    font-size: 1.5rem; /* Adjust icon size */
}
.card-blog h5 {
    font-weight: 700;
    color: #344767; /* Darker text for headings */
}
.card-blog p {
    color: #67748e; /* Softer text for descriptions */
}
.card-blog .text-decoration-none {
    text-decoration: none !important;
}
.absolute-center {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}

/* Specific color adjustments for cards */
.card-blog-success { background: linear-gradient(195deg, #66BB6A, #4CAF50); }
.card-blog-info { background: linear-gradient(195deg, #4FC3F7, #03A9F4); }
.card-blog-dark { background: linear-gradient(195deg, #344767, #1A202C); }
.card-blog-warning { background: linear-gradient(195deg, #FFA726, #FF9800); }
.card-blog-primary { background: linear-gradient(195deg, #6E78E8, #3F51B5); } /* Soft UI primary */
</style>

{{-- Chart.js Initialization Script --}}
{{-- Chart.js is assumed to be loaded by the layout's soft-ui-dashboard.min.js --}}
<script src="{{ asset('assets/js/plugins/chartjs.min.js') }}"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Helper function to fetch data and render chart
    function fetchAndRenderChart(canvasId, url, chartType, chartLabel, dataKey, colors) {
        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                const ctx = document.getElementById(canvasId).getContext('2d');
                
                const chartDataPoints = data[dataKey];
                if (!chartDataPoints || !Array.isArray(chartDataPoints)) {
                    console.error(`Data key "${dataKey}" not found or is not an array in API response.`);
                    document.getElementById(canvasId).parentElement.innerHTML = '<p>Could not load chart data: Invalid API response.</p>';
                    return;
                }

                const labels = chartDataPoints.map(item => item.label || item.incident_type || item.status || item.location);
                const counts = chartDataPoints.map(item => item.count);

                const chartData = {
                    labels: labels,
                    datasets: [{
                        label: chartLabel,
                        data: counts,
                        backgroundColor: colors.slice(0, chartDataPoints.length),
                        borderColor: colors.slice(0, chartDataPoints.length).map(c => c.replace('0.6)', '1)')), // Make border opaque
                        borderWidth: 1
                    }]
                };

                new Chart(ctx, {
                    type: chartType,
                    data: chartData,
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            title: { display: false }
                        },
                        scales: {
                            y: { beginAtZero: true }
                        }
                    }
                });
            })
            .catch(error => {
                console.error(`Error fetching chart data for ${canvasId}:`, error);
                document.getElementById(canvasId).parentElement.innerHTML = '<p>Could not load chart data.</p>';
            });
    }

    // Chart Colors (extend these arrays if you have many categories)
    const statusColors = ['rgba(255, 159, 64, 0.6)', 'rgba(54, 162, 235, 0.6)', 'rgba(75, 192, 192, 0.6)', 'rgba(153, 102, 255, 0.6)', 'rgba(255, 99, 132, 0.6)'];
    const typeColors = ['rgba(54, 162, 235, 0.6)', 'rgba(255, 206, 86, 0.6)', 'rgba(75, 192, 192, 0.6)', 'rgba(153, 102, 255, 0.6)', 'rgba(255, 99, 132, 0.6)'];
    const areaColors = ['rgba(54, 162, 235, 0.6)', 'rgba(75, 192, 192, 0.6)', 'rgba(255, 206, 86, 0.6)', 'rgba(153, 102, 255, 0.6)', 'rgba(255, 99, 132, 0.6)'];

    // Render Reports by Status Chart (Pie Chart)
    fetchAndRenderChart('reportsByStatusChart', '/api/admin/analytics/reports-overview', 'pie', 'Reports by Status', 'by_status', statusColors);

    // Render Reports by Incident Type Chart (Bar Chart)
    fetchAndRenderChart('reportsByTypeChart', '/api/admin/analytics/reports-overview', 'bar', 'Number of Reports', 'by_type', typeColors);

    // Render Reports by Area Chart (Bar Chart)
    fetchAndRenderChart('reportsByAreaChart', '/api/admin/analytics/area-insights', 'bar', 'Number of Reports', 'data', areaColors); // Note: area-insights returns array directly, not in 'data' key.
});
</script>
@endsection
