@extends('layouts.app')

@section('content')
<div class="row">
    <div class="col-12">
        <div class="card mb-4 mx-4">
            <div class="card-header pb-0">
                <div class="d-flex flex-row justify-content-between">
                    <div>
                        <h5 class="mb-0">All Staff</h5>
                    </div>
                    <button type="button" class="btn bg-gradient-primary btn-sm mb-0" data-bs-toggle="modal" data-bs-target="#newStaffModal">+&nbsp; New Staff</button>
                </div>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive p-0">
                    <table class="table align-items-center mb-0">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">ID</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Name</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Email / Location</th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 text-center">Organization</th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($staff as $member)
                            <tr>
                                <td class="ps-4"><p class="text-xs font-weight-bold mb-0">{{ $member->id }}</p></td>
                                <td><p class="text-xs font-weight-bold mb-0">{{ $member->name }}</p></td>
                                <td>
                                    <p class="text-xs font-weight-bold mb-0">{{ $member->email }}</p>
                                    <p class="text-xs text-secondary mb-0">{{ $member->location ?? 'No location set' }}</p>
                                </td>
                                <td class="text-center">
                                    <p class="text-xs font-weight-bold mb-0">{{ $member->organization->name ?? 'N/A' }}</p>
                                </td>
                                <td class="text-center">
                                    <div class="d-flex align-items-center justify-content-center">
                                        <a href="{{ route('admin.staff.impersonate', $member->id) }}" class="mx-2" data-bs-toggle="tooltip" data-bs-original-title="Login as Staff">
                                            <i class="fas fa-sign-in-alt text-info"></i>
                                        </a>
                                        <a href="#" class="mx-2" data-bs-toggle="tooltip" data-bs-original-title="Edit staff">
                                            <i class="fas fa-user-edit text-secondary"></i>
                                        </a>
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

<!-- Modal for New Staff -->
<div class="modal fade" id="newStaffModal" tabindex="-1" role="dialog" aria-labelledby="newStaffModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="newStaffModalLabel">Add New Staff Member</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="{{ route('admin.staff.create') }}" method="POST">
          @csrf
          <div class="modal-body text-start">
            <div class="form-group">
                <label for="name">Name</label>
                <input type="text" class="form-control" name="name" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" class="form-control" name="email" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" class="form-control" name="password" required>
            </div>
            <div class="form-group">
                <label for="location">Location</label>
                <input type="text" class="form-control" name="location">
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn bg-gradient-secondary" data-bs-dismiss="modal">Close</button>
            <button type="submit" class="btn bg-gradient-primary">Create Staff</button>
          </div>
      </form>
    </div>
  </div>
</div>
@endsection
