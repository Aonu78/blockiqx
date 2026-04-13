@extends('layouts.app')

@section('content')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
<style>
    #map { height: 600px; border-radius: 15px; }
    .filter-card { margin-bottom: 20px; }
</style>

<div class="row">
    <div class="col-12">
        <div class="card filter-card mx-4">
            <div class="card-body p-3">
                <form id="map-filters" class="row align-items-end">
                    <div class="col-md-2">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-control form-control-sm">
                            <option value="all">All Statuses</option>
                            <option value="Pending">Pending</option>
                            <option value="In Progress">In Progress</option>
                            <option value="Completed">Completed</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Type</label>
                        <select name="incident_type" class="form-control form-control-sm">
                            <option value="all">All Types</option>
                            @foreach(\App\Models\Report::select('incident_type')->distinct()->get() as $type)
                            <option value="{{ $type->incident_type }}">{{ $type->incident_type }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">From</label>
                        <input type="date" name="date_from" class="form-control form-control-sm">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">To</label>
                        <input type="date" name="date_to" class="form-control form-control-sm">
                    </div>
                    <div class="col-md-2">
                        <button type="button" id="apply-filters" class="btn bg-gradient-primary btn-sm mb-0">Apply Filters</button>
                    </div>
                </form>
            </div>
        </div>
        
        <div class="card mx-4">
            <div class="card-header pb-0">
                <h6>Incident Hotspots & Staff Locations</h6>
            </div>
            <div class="card-body p-3">
                <div id="map"></div>
            </div>
        </div>
    </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var map = L.map('map').setView([40.7128, -74.0060], 13);
        var markers = L.layerGroup().addTo(map);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        function loadMapData() {
            const formData = new FormData(document.getElementById('map-filters'));
            const params = new URLSearchParams(formData).toString();

            fetch(`/api/admin/analytics/map-view?${params}`, {
                headers: {
                    'Accept': 'application/json',
                    // Add your auth token here if required
                }
            })
            .then(response => response.json())
            .then(data => {
                markers.clearLayers();
                
                // Add Reports
                data.reports.forEach(report => {
                    const color = report.status === 'Completed' ? 'green' : (report.status === 'Pending' ? 'orange' : 'blue');
                    const marker = L.circleMarker([report.latitude, report.longitude], {
                        color: color,
                        fillColor: color,
                        fillOpacity: 0.5,
                        radius: 8
                    }).bindPopup(`
                        <strong>${report.incident_type}</strong><br>
                        Status: ${report.status}<br>
                        Location: ${report.location}<br>
                        <small>${report.description}</small>
                    `);
                    markers.addLayer(marker);
                });

                // Focus map on markers if any
                if (data.reports.length > 0) {
                    const group = new L.featureGroup(markers.getLayers());
                    map.fitBounds(group.getBounds());
                }
            });
        }

        document.getElementById('apply-filters').addEventListener('click', loadMapData);
        loadMapData();
    });
</script>
@endsection
