<div class="row">
    <div class="col-12">
        <div class="card mb-4 mx-4">
            <div class="card-header pb-0">
                <div class="d-flex flex-row justify-content-between">
                    <div>
                        <h5 class="mb-0">All Users</h5>
                    </div>
                    <a href="#" class="btn bg-gradient-primary btn-sm mb-0" type="button">+&nbsp; New User</a>
                </div>
            </div>
            <div class="card-body px-0 pt-0 pb-2">
                <div class="table-responsive p-0">
                    <table class="table align-items-center mb-0">
                        <thead>
                            <tr>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                                    ID
                                </th>
                                <th class="text-uppercase text-secondary text-xxs font-weight-bolder opacity-7 ps-2">
                                    Photo
                                </th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                                    Name
                                </th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                                    Email
                                </th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                                    Creation Date
                                </th>
                                <th class="text-center text-uppercase text-secondary text-xxs font-weight-bolder opacity-7">
                                    Action
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($users as $user)
                            <tr>
                                <td class="ps-4">
                                    <p class="text-xs font-weight-bold mb-0">{{ $user->id }}</p>
                                </td>
                                <td>
                                    <div>
                                        <img src="https://soft-ui-dashboard-laravel.creative-tim.com/assets/img/team-2.jpg" class="avatar avatar-sm me-3">
                                    </div>
                                </td>
                                <td class="text-center">
                                    <p class="text-xs font-weight-bold mb-0">{{ $user->name }}</p>
                                </td>
                                <td class="text-center">
                                    <p class="text-xs font-weight-bold mb-0">{{ $user->email }}</p>
                                </td>
                                <td class="text-center">
                                    <span class="text-secondary text-xs font-weight-bold">{{ $user->created_at->format('d/m/y') }}</span>
                                </td>
                                <td class="text-center">
                                    <div class="d-flex align-items-center justify-content-center">
                                        <form action="{{ route('admin.users.promote', $user->id) }}" method="POST">
                                            @csrf
                                            <button type="submit" class="btn btn-link p-0 m-0 mx-2" data-bs-toggle="tooltip" title="Promote to Staff">
                                                <i class="fas fa-user-plus text-success"></i>
                                            </button>
                                        </form>
                                        <button type="button" class="btn btn-link p-0 m-0 mx-3"
                                            data-bs-toggle="modal"
                                            data-bs-target="#editUserModal{{ $user->id }}"
                                            data-bs-original-title="Edit user">
                                            <i class="fas fa-user-edit text-secondary"></i>
                                        </button>
                                        <span>
                                            <i class="cursor-pointer fas fa-trash text-secondary"></i>
                                        </span>
                                    </div>
                                </td>
                            </tr>

                            <div class="modal fade" id="editUserModal{{ $user->id }}" tabindex="-1"
                                role="dialog" aria-labelledby="editUserModalLabel{{ $user->id }}" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered" role="document">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="editUserModalLabel{{ $user->id }}">Edit {{ $user->name }}</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                aria-label="Close"></button>
                                        </div>
                                        <form action="{{ route('admin.users.update', $user->id) }}" method="POST">
                                            @csrf
                                            @method('PUT')
                                            <div class="modal-body text-start">
                                                <div class="form-group">
                                                    <label for="name{{ $user->id }}">Name</label>
                                                    <input id="name{{ $user->id }}" type="text" class="form-control"
                                                        name="name" value="{{ $user->name }}" required>
                                                </div>
                                                <div class="form-group">
                                                    <label for="email{{ $user->id }}">Email</label>
                                                    <input id="email{{ $user->id }}" type="email" class="form-control"
                                                        name="email" value="{{ $user->email }}" required>
                                                </div>
                                                <div class="form-group">
                                                    <label for="password{{ $user->id }}">New Password</label>
                                                    <input id="password{{ $user->id }}" type="password" class="form-control"
                                                        name="password">
                                                </div>
                                                <div class="form-group">
                                                    <label for="password_confirmation{{ $user->id }}">Confirm New Password</label>
                                                    <input id="password_confirmation{{ $user->id }}" type="password"
                                                        class="form-control" name="password_confirmation">
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn bg-gradient-secondary"
                                                    data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn bg-gradient-primary">Save Changes</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
