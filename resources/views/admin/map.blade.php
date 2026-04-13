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
                <form id="map-filters" class="row align-items-end gy-3">
                    <div class="col-md-2">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-control form-control-sm">
                            <option value="all">All Statuses</option>
                            @foreach($statuses as $status)
                            <option value="{{ $status }}">{{ $status }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Type</label>
                        <select name="incident_type" class="form-control form-control-sm">
                            <option value="all">All Types</option>
                            @foreach($incidentTypes as $type)
                            <option value="{{ $type }}">{{ $type }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Organization</label>
                        <select name="organization_id" class="form-control form-control-sm">
                            <option value="all">All Organizations</option>
                            @foreach($organizations as $org)
                            <option value="{{ $org->id }}">{{ $org->name }}</option>
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
                        <button type="button" id="apply-filters" class="btn bg-gradient-primary btn-sm mb-0 w-100">Apply Filters</button>
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
        var map = L.map('map').setView([40.7128, -74.0060], 10); // Adjusted zoom for better initial view
        var reportMarkers = L.layerGroup().addTo(map);
        var staffMarkers = L.layerGroup().addTo(map);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        // Function to get color based on status or concern level
        function getStatusColor(status) {
            switch(status) {
                case 'Completed': return 'green';
                case 'In Progress': return 'blue';
                case 'Arrived at location': return 'purple';
                case 'Work started': return 'cyan';
                case 'Pending': return 'orange';
                default: return 'gray';
            }
        }

        function getConcernColor(concern) {
            switch(concern) {
                case 'High': return 'red';
                case 'Medium': return 'orange';
                case 'Low': return 'green';
                default: return 'gray';
            }
        }

        function loadMapData() {
            const form = document.getElementById('map-filters');
            const formData = new FormData(form);
            const params = new URLSearchParams(formData).toString();

            fetch(`/api/admin/analytics/map-view?${params}`, {
                headers: {
                    'Accept': 'application/json',
                    // Add Authorization header if auth:sanctum middleware is applied to this route
                    // 'Authorization': 'Bearer ' + localStorage.getItem('api_token') 
                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                reportMarkers.clearLayers();
                staffMarkers.clearLayers();
                
                // Add Reports
                data.reports.forEach(report => {
                    const reportColor = getStatusColor(report.status);
                    const concernColor = getConcernColor(report.concern_level);

                    const popupContent = `
                        <strong>${report.incident_type}</strong><br>
                        Category: ${report.category || 'N/A'}<br>
                        Status: <span style="color: ${reportColor}; font-weight: bold;">${report.status}</span><br>
                        Concern: <span style="color: ${concernColor}; font-weight: bold;">${report.concern_level}</span><br>
                        Location: ${report.location}<br>
                        Coords: (${report.latitude.toFixed(4)}, ${report.longitude.toFixed(4)})<br>
                        <small>Description: ${report.description.substring(0, 50)}...</small>
                    `;
                    const marker = L.circleMarker([report.latitude, report.longitude], {
                        color: reportColor,
                        fillColor: reportColor,
                        fillOpacity: 0.7,
                        radius: 8
                    }).bindPopup(popupContent);
                    reportMarkers.addLayer(marker);
                });

                // Add Staff Locations
                data.staff.forEach(staff => {
                    // Assuming staff location is stored as a string like "lat,lng" or can be parsed.
                    // If staff has lat/long columns directly, use staff.latitude, staff.longitude
                    // For now, using a placeholder and assuming location is a parseable string or placeholder
                    const staffLocation = staff.latitude && staff.longitude ? [staff.latitude, staff.longitude] : null;
                    if (staffLocation) {
                        const staffMarker = L.marker(staffLocation, {
                            icon: L.divIcon({className: 'staff-icon', html: `<i class="fas fa-user-tie" style="color: purple; font-size: 24px;"></i>`, iconSize: [24, 24]})
                        }).bindPopup(`
                            <strong>${staff.name}</strong><br>
                            Location: ${staff.location}<br>
                            Org: ${staff.organization?.name ?? 'N/A'}
                        `);
                        staffMarkers.addLayer(staffMarker);
                    }
                });

                // Adjust map bounds to fit all markers
                const allMarkers = L.featureGroup([...reportMarkers.getLayers(), ...staffMarkers.getLayers()]);
                if (allMarkers.getLayers().length > 0) {
                    map.fitBounds(allMarkers.getBounds());
                }
            })
            .catch(error => {
                console.error('Error fetching map data:', error);
                alert('Failed to load map data. Please try again.');
            });
        }

        document.getElementById('apply-filters').addEventListener('click', loadMapData);
        loadMapData();
    });
</script>
@endsection
