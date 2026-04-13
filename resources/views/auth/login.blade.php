@extends('layouts.auth') {{-- Assuming 'auth' layout exists or adapt as needed --}}

@section('content')
<div class="container py-5">
    <div class="row justify-content-center" style="border: 1px solid;border-radius: 20px;">
        <div class="col-md-12">
            <div class="card card-plain">
                <div class="card-header text-center pb-0">
                    <h4 class="font-weight-bolder text-dark text-gradient">Welcome Back</h4>
                    <p class="mb-0">Enter email and password to sign in</p>
                </div>
                <div class="card-body">
                    <form role="form" action="{{ route('login') }}" method="POST">
                        @csrf
                        <div class="mb-3">
                            <label for="email" class="form-label">Email Address</label>
                            <input type="email" class="form-control" id="email" name="email" placeholder="Email" aria-label="Email" value="{{ old('email') }}" required>
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control" id="password" name="password" placeholder="Password" aria-label="Password" required>
                        </div>
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" id="rememberMe" name="remember" {{ old('remember') ? 'checked' : '' }}>
                            <label class="form-check-label" for="rememberMe">Remember me</label>
                        </div>
                        <div class="text-center">
                            <button type="submit" class="btn btn-lg bg-gradient-primary btn-lg w-100 mt-4 mb-2">Sign in</button>
                        </div>
                    </form>
                </div>
                <div class="card-footer text-center pt-0 px-lg-2 px-1">
                    <p class="mb-4 text-sm mx-auto">
                        Don't have an account?
                        <a href="{{ route('register') }}" class="text-primary text-gradient font-weight-bold">Sign up</a>
                    </p>
                    {{-- Link for password reset if implemented --}}
                    {{-- <p class="mb-2 text-sm mx-auto">
                        Forgot your password?
                        <a href="{{ route('password.request') }}" class="text-primary text-gradient font-weight-bold">Reset Password</a>
                    </p> --}}
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
