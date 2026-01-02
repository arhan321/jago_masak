<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $data = $request->validate([
            'name' => ['required','string','max:255'],
            'email' => ['required','email','max:255','unique:users,email'],
            'password' => ['required','string','min:8'],
            'nomor_telfon' => ['nullable','string','max:20'],
        ]);

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'], // cast hashed di User model
            'nomor_telfon' => $data['nomor_telfon'] ?? null,
            'role' => 'user',
        ]);

        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required','email'],
            'password' => ['required','string'],
        ]);

        if (!Auth::attempt($data)) {
            return response()->json(['message' => 'Email/password salah'], 401);
        }

        $user = $request->user();
        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['message' => 'Logged out']);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    public function totalPengguna()
    {
        $total = User::count();

        // kalau kamu mau hanya user role "user" saja:
        // $total = User::where('role', 'user')->count();

        // kalau mau pecahan admin vs user:
        $totalUser = User::where('role', 'user')->count();
        $totalAdmin = User::where('role', 'admin')->count();

        return response()->json([
            'total_pengguna' => $total,
            'total_user' => $totalUser,
            'total_admin' => $totalAdmin,
        ]);
    }

        public function users()
    {
        // tampilkan role user saja (kalau kamu mau include admin, hapus where)
        $users = User::query()
            ->where('role', 'user')
            ->select(['id', 'name', 'email', 'role', 'nomor_telfon', 'created_at'])
            ->latest()
            ->get();

        return response()->json($users);
    }
}
