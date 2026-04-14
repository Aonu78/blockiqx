@extends('layouts.app')

@section('content')
    <div class="row">
        <div class="col-12">
            <div class="card mb-4 mx-4">
                <div class="card-header pb-0 d-flex justify-content-between align-items-start">
                    <div>
                        <h5 class="mb-1">Report #{{ $report->id }}</h5>
                        <p class="text-sm mb-0 text-secondary">{{ $report->incident_type }} at {{ $report->location }}</p>
                    </div>
                    <a href="{{ route('admin.reports') }}" class="btn bg-gradient-secondary btn-sm mb-0">Back</a>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 mb-4">
                            <h6 class="text-uppercase text-xs text-secondary">Report Details</h6>
                            <ul class="list-group">
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Status</span>
                                    <span class="badge bg-gradient-{{ $report->status === 'Completed' ? 'success' : ($report->status === 'Pending' ? 'warning' : 'primary') }}">{{ $report->status }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Category</span>
                                    <span>{{ $report->category ?? 'N/A' }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Concern Level</span>
                                    <span>{{ $report->concern_level ?? 'N/A' }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Organization</span>
                                    <span>{{ $report->organization->name ?? 'N/A' }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Assigned Staff</span>
                                    <span>{{ $report->assignedStaff->name ?? 'Unassigned' }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Submitted By</span>
                                    <span>{{ $report->is_anonymous ? 'Anonymous' : ($report->user->name ?? $report->email ?? 'Unknown') }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Created</span>
                                    <span>{{ optional($report->created_at)->format('d M Y h:i A') ?? 'N/A' }}</span>
                                </li>
                            </ul>
                        </div>
                        <div class="col-md-6 mb-4">
                            <h6 class="text-uppercase text-xs text-secondary">Assignment</h6>
                            <form action="{{ route('admin.reports.assign', $report->id) }}" method="POST" class="mb-4">
                                @csrf
                                <div class="form-group">
                                    <label for="staff_id" class="form-control-label">Assign to Staff</label>
                                    <select class="form-control" name="staff_id" id="staff_id" required>
                                        <option value="">Select staff member</option>
                                        @foreach ($staffMembers as $staff)
                                            <option value="{{ $staff->id }}" @selected($report->assigned_to === $staff->id)>
                                                {{ $staff->name }}{{ $staff->organization ? ' - ' . $staff->organization->name : '' }}
                                            </option>
                                        @endforeach
                                    </select>
                                </div>
                                <button type="submit" class="btn bg-gradient-primary btn-sm mb-0">Save Assignment</button>
                            </form>

                            <h6 class="text-uppercase text-xs text-secondary">Description</h6>
                            <div class="border rounded p-3 bg-light">
                                <p class="text-sm mb-0">{{ $report->description ?: 'No description provided.' }}</p>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-4">
                            <h6 class="text-uppercase text-xs text-secondary">Contact & Location</h6>
                            <ul class="list-group">
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Email</span>
                                    <span>{{ $report->email ?? 'N/A' }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Phone</span>
                                    <span>{{ $report->phone_number ?? 'N/A' }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Location</span>
                                    <span>{{ $report->location ?? 'N/A' }}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span>Coordinates</span>
                                    <span>
                                        @if ($report->latitude && $report->longitude)
                                            {{ $report->latitude }}, {{ $report->longitude }}
                                        @else
                                            N/A
                                        @endif
                                    </span>
                                </li>
                            </ul>
                        </div>
                        <div class="col-md-6 mb-4">
                            <h6 class="text-uppercase text-xs text-secondary">Field Notes</h6>
                            <div class="border rounded p-3 bg-light">
                                @forelse (($report->notes ?? []) as $note)
                                    <div class="mb-3">
                                        <p class="text-sm mb-1">{{ $note['note'] ?? '' }}</p>
                                        <p class="text-xs text-secondary mb-0">
                                            Staff #{{ $note['user_id'] ?? 'N/A' }}
                                            @if (!empty($note['timestamp']))
                                                • {{ \Illuminate\Support\Carbon::parse($note['timestamp'])->format('d M Y h:i A') }}
                                            @endif
                                        </p>
                                    </div>
                                @empty
                                    <p class="text-sm mb-0 text-secondary">No notes added yet.</p>
                                @endforelse
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
