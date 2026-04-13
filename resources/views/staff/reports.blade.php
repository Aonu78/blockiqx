@extends('layouts.app')

@section('content')
<div class="row">
    <div class="col-12">
        <div class="card mb-4 mx-4">
            <div class="card-header pb-0">
                <h5 class="mb-0">My Assigned Reports</h5>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive p-0">
                    <table class="table align-items-center mb-0">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">ID</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Type</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Location</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Status</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($reports as $report)
                            <tr>
                                <td class="ps-4"><p class="text-xs font-weight-bold mb-0">{{ $report->id }}</p></td>
                                <td><p class="text-xs font-weight-bold mb-0">{{ $report->incident_type }}</p></td>
                                <td><p class="text-xs font-weight-bold mb-0">{{ $report->location }}</p></td>
                                <td class="text-center">
                                    <span class="badge badge-sm bg-gradient-{{ $report->status == 'Completed' ? 'success' : ($report->status == 'Pending' ? 'warning' : 'primary') }}">
                                        {{ $report->status }}
                                    </span>
                                </td>
                                <td class="text-center">
                                    <div class="btn-group">
                                        <button type="button" class="btn btn-sm btn-outline-primary dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
                                          Update Status
                                        </button>
                                        <ul class="dropdown-menu">
                                          @foreach(['Arrived at location', 'Work started', 'In Progress', 'Completed'] as $status)
                                          <li>
                                              <form action="{{ route('staff.reports.status', $report->id) }}" method="POST">
                                                  @csrf
                                                  @method('PUT')
                                                  <input type="hidden" name="status" value="{{ $status }}">
                                                  <button type="submit" class="dropdown-item">{{ $status }}</button>
                                              </form>
                                          </li>
                                          @endforeach
                                        </ul>
                                      </div>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="5" class="text-center p-4">
                                    <p class="text-secondary">No reports assigned to you.</p>
                                </td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
