@extends('layouts.app')

@section('content')
<div class="row">
    <div class="col-12">
        <div class="card mb-4 mx-4">
            <div class="card-header pb-0">
                <h5 class="mb-0">All Reports</h5>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive p-0">
                    <table class="table align-items-center mb-0">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">ID</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Type / Category</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Location (Geo)</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Concern</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Organization</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Status</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($reports as $report)
                            <tr>
                                <td class="ps-4"><p class="text-xs font-weight-bold mb-0">{{ $report->id }}</p></td>
                                <td>
                                    <p class="text-xs font-weight-bold mb-0">{{ $report->incident_type }}</p>
                                    <p class="text-xs text-secondary mb-0">{{ $report->category }}</p>
                                </td>
                                <td>
                                    <p class="text-xs font-weight-bold mb-0">{{ $report->location }}</p>
                                    @if($report->latitude && $report->longitude)
                                    <p class="text-xs text-secondary mb-0">({{ $report->latitude }}, {{ $report->longitude }})</p>
                                    @endif
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-sm bg-{{ $report->concern_level == 'High' ? 'danger' : ($report->concern_level == 'Medium' ? 'warning' : 'info') }}">
                                        {{ $report->concern_level }}
                                    </span>
                                </td>
                                <td class="text-center">
                                    <p class="text-xs font-weight-bold mb-0">{{ $report->organization->name ?? 'N/A' }}</p>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-sm bg-gradient-{{ $report->status == 'Completed' ? 'success' : ($report->status == 'Pending' ? 'warning' : 'primary') }}">
                                        {{ $report->status }}
                                    </span>
                                </td>
                                <td class="text-center">
                                    <div class="d-flex align-items-center justify-content-center">
                                        <a href="#" class="mx-3" data-bs-toggle="tooltip" data-bs-original-title="View details">
                                            <i class="fas fa-eye text-secondary"></i>
                                        </a>
                                        <div class="dropdown">
                                            <button class="btn btn-link text-secondary mb-0" id="dropdownMenuButton{{ $report->id }}" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                <i class="fa fa-ellipsis-v text-xs"></i>
                                            </button>
                                            <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton{{ $report->id }}">
                                                <li class="dropdown-header">Assign to Staff</li>
                                                @foreach(\App\Models\Staff::all() as $staff)
                                                <li>
                                                    <form action="{{ route('admin.reports.assign', $report->id) }}" method="POST">
                                                        @csrf
                                                        <input type="hidden" name="staff_id" value="{{ $staff->id }}">
                                                        <button type="submit" class="dropdown-item">{{ $staff->name }}</button>
                                                    </form>
                                                </li>
                                                @endforeach
                                            </ul>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
