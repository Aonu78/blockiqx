@extends('layouts.app')

@section('content')
<div class="row">
    <div class="col-12">
        <div class="card mb-4 mx-4">
            <div class="card-header pb-0">
                <h5 class="mb-0">Analytics Dashboard</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3">
                        <div class="card shadow-none border bg-light text-center">
                            <div class="card-body">
                                <h6>Total Reports</h6>
                                <h4>{{ \App\Models\Report::count() }}</h4>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-none border bg-light text-center">
                            <div class="card-body">
                                <h6>Completed Cases</h6>
                                <h4>{{ \App\Models\Report::where('status', 'Completed')->count() }}</h4>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-none border bg-light text-center">
                            <div class="card-body">
                                <h6>Pending Cases</h6>
                                <h4>{{ \App\Models\Report::where('status', 'Pending')->count() }}</h4>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card shadow-none border bg-light text-center">
                            <div class="card-body">
                                <h6>Total Staff</h6>
                                <h4>{{ \App\Models\Staff::count() }}</h4>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="card shadow-none border">
                            <div class="card-body">
                                <h6>Reports by Incident Type</h6>
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>Type</th>
                                            <th>Count</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach(\App\Models\Report::select('incident_type', \DB::raw('count(*) as count'))->groupBy('incident_type')->get() as $item)
                                        <tr>
                                            <td>{{ $item->incident_type }}</td>
                                            <td>{{ $item->count }}</td>
                                        </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card shadow-none border">
                            <div class="card-body">
                                <h6>Reports by Area</h6>
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>Location</th>
                                            <th>Count</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach(\App\Models\Report::select('location', \DB::raw('count(*) as count'))->groupBy('location')->orderBy('count', 'desc')->get() as $item)
                                        <tr>
                                            <td>{{ $item->location }}</td>
                                            <td>{{ $item->count }}</td>
                                        </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
