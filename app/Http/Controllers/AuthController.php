<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Staff;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\Route; // Ensure Route facade is imported if used directly for route() helper, though usually not needed here.
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    // --- Web Authentication Methods ---

    public function showLoginForm()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Try to authenticate as staff first using the 'staff' guard
        if (Auth::guard('staff')->attempt($request->only('email', 'password'))) {
            return redirect()->intended('/staff/reports'); // Redirect staff to their dashboard
        }

        // If staff authentication fails, try authenticating as a regular user using the 'web' guard
        if (Auth::guard('web')->attempt($request->only('email', 'password'))) {
            return redirect()->intended('/admin/dashboard'); // Redirect admin/user to admin dashboard
        }

        // If both fail, throw an error
        throw ValidationException::withMessages([
            'email' => ['The provided credentials do not match our records.'],
        ]);
    }

    public function showRegistrationForm()
    {
        return view('auth.register');
    }

    public function register(Request $request)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $validatedData['name'],
            'email' => $validatedData['email'],
            'password' => Hash::make($validatedData['password']),
        ]);

        Auth::guard('web')->login($user); // Log in the newly registered user

        return redirect()->route('admin.dashboard')->with('success', 'Welcome aboard!');
    }

    public function logout(Request $request)
    {
        // Log out from the currently active guard (web or staff)
        if (Auth::guard('staff')->check()) {
            Auth::guard('staff')->logout();
        } elseif (Auth::guard('web')->check()) {
            Auth::guard('web')->logout();
        }

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login'); // Redirect to login page after logout
    }

    // --- API Authentication Methods --- (Keep these separate if needed)

    public function userLogin(Request $request) // API login for users
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        return response()->json([
            'token' => $user->createToken('user-token')->plainTextToken,
            'user' => $user
        ]);
    }

    public function staffLogin(Request $request) // API login for staff
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $staff = Staff::where('email', $request->email)->first();

        if (!$staff || !Hash::check($request->password, $staff->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        return response()->json([
            'token' => $staff->createToken('staff-token')->plainTextToken,
            'staff' => $staff
        ]);
    }
}
