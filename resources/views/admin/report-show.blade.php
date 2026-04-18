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
                    <a href="{{ route('admin.reports') }}" class="btn bg-gradient-secondary btn-sm mb-0">Back to Reports</a>
                </div>
                <div class="card-body">
                    <div class="row">
                        {{-- Left Column: Report Details --}}
                        <div class="col-lg-7">
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
                                                    <a href="https://www.google.com/maps/search/?api=1&query={{ $report->latitude }},{{ $report->longitude }}" target="_blank">{{ $report->latitude }}, {{ $report->longitude }}</a>
                                                @else
                                                    N/A
                                                @endif
                                            </span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <h6 class="text-uppercase text-xs text-secondary">Description</h6>
                            <div class="border rounded p-3 bg-light mb-4">
                                <p class="text-sm mb-0">{{ $report->description ?: 'No description provided.' }}</p>
                            </div>
                        </div>

                        {{-- Right Column: Management & Notes --}}
                        <div class="col-lg-5">
                            <h6 class="text-uppercase text-xs text-secondary">Manage Report</h6>
                            <form action="{{ route('admin.reports.update', $report->id) }}" method="POST" class="mb-4">
                                @csrf
                                @method('PUT')

                                <div class="form-group">
                                    <label for="status" class="form-control-label">Update Status</label>
                                    <select class="form-control" name="status" id="status" required>
                                        @foreach (['Pending', 'In Progress', 'Arrived at location', 'Work started', 'Completed'] as $status)
                                            <option value="{{ $status }}" @selected($report->status === $status)>{{ $status }}</option>
                                        @endforeach
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="staff_id" class="form-control-label">Assign to Staff</label>
                                    <select class="form-control" name="staff_id" id="staff_id">
                                        <option value="">-- Unassign --</option>
                                        @foreach ($staffMembers as $staff)
                                            <option value="{{ $staff->id }}" @selected($report->assigned_to === $staff->id)>
                                                {{ $staff->name }}{{ $staff->organization ? ' - ' . $staff->organization->name : '' }}
                                            </option>
                                        @endforeach
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="note" class="form-control-label">Add Note</label>
                                    <textarea class="form-control" name="note" id="note" rows="3" placeholder="Add an internal note or comment..."></textarea>
                                </div>

                                <button type="submit" class="btn bg-gradient-primary w-100 mb-0">Update Report</button>
                            </form>

                            <h6 class="text-uppercase text-xs text-secondary">Activity & Notes</h6>
                            <div class="border rounded p-3 bg-light" style="max-height: 400px; overflow-y: auto;">
                                @forelse ($report->notes->sortByDesc('created_at') as $note)
                                    <div class="mb-3 border-bottom pb-2">
                                        <p class="text-sm mb-1">{{ $note->note }}</p>
                                        <p class="text-xs text-secondary mb-0">
                                            <strong>{{ $note->user->name ?? 'System' }}</strong>
                                            &nbsp;&middot;&nbsp;
                                            {{ $note->created_at->format('d M Y, h:i A') }}
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
