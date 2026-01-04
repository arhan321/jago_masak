<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
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

// public function updateById(Request $request, $id)
// {
//     try {
//         $user = $request->user();

//         // ✅ memastikan yang login ada
//         if (!$user) {
//             return response()->json(['message' => 'Unauthenticated'], 401);
//         }

//         // ✅ memastikan hanya bisa edit akun sendiri (tanpa filter role)
//         if ((int)$user->id !== (int)$id) {
//             return response()->json(['message' => 'Forbidden: tidak boleh edit user lain'], 403);
//         }

//         $data = $request->validate([
//             'name' => ['sometimes', 'required', 'string', 'max:255'],
//             'email' => ['sometimes', 'required', 'email', 'max:255', 'unique:users,email,' . $user->id],
//             'nomor_telfon' => ['sometimes', 'nullable', 'string', 'max:20'],
//             'password' => ['sometimes', 'nullable', 'string', 'min:8'],
//         ]);

//         // kalau password dikirim tapi kosong, jangan update
//         if (array_key_exists('password', $data) && empty($data['password'])) {
//             unset($data['password']);
//         }

//         $user->update($data);

//         return response()->json([
//             'message' => 'Akun berhasil diupdate',
//             'data' => $user->only(['id','name','email','nomor_telfon','role','created_at','updated_at']),
//         ], 200);

//     } catch (\Throwable $e) {
//         // ✅ supaya kamu bisa lihat errornya jelas (tidak HTML)
//         Log::error('updateById error: '.$e->getMessage());

//         return response()->json([
//             'message' => 'Server error',
//             'error' => $e->getMessage(), // sementara untuk debugging
//         ], 500);
//     }
// }

// public function updateMe(Request $request)
// {
//     $user = $request->user();

//     // ✅ biar tidak 500 kalau belum login
//     if (!$user) {
//         return response()->json(['message' => 'Unauthenticated'], 401);
//     }

//     $data = $request->validate([
//         'name' => ['sometimes', 'required', 'string', 'max:255'],
//         'email' => ['sometimes', 'required', 'email', 'max:255', 'unique:users,email,' . $user->id],
//         'nomor_telfon' => ['sometimes', 'nullable', 'string', 'max:20'],
//         'password' => ['sometimes', 'nullable', 'string', 'min:8'],
//     ]);

//     // kalau password dikirim tapi kosong, jangan update password
//     if (array_key_exists('password', $data) && empty($data['password'])) {
//         unset($data['password']);
//     }

//     $user->update($data);

//     return response()->json([
//         'message' => 'Akun berhasil diupdate',
//         'data' => $user->only(['id','name','email','nomor_telfon','role','created_at','updated_at']),
//     ], 200);
// }

public function updateById(Request $request, $id)
{
    $data = $request->validate([
        'name' => ['sometimes', 'required', 'string', 'max:255'],
        'email' => ['sometimes', 'required', 'email', 'max:255', 'unique:users,email,' . $id],
        'nomor_telfon' => ['sometimes', 'nullable', 'string', 'max:20'],
        'password' => ['sometimes', 'nullable', 'string', 'min:8'],
    ]);

    if (array_key_exists('password', $data) && empty($data['password'])) {
        unset($data['password']);
    }

    $targetUser = \App\Models\User::findOrFail($id);
    $targetUser->update($data);

    return response()->json([
        'message' => 'User berhasil diupdate',
        'data' => $targetUser->only(['id','name','email','nomor_telfon','role','created_at','updated_at']),
    ], 200);
}


}
