<?php

namespace App\Http\Controllers;

use App\Models\Recipe;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class FavoriteController extends Controller
{
 public function index(Request $request)
{
    $user = $request->user(); // sekarang pasti ada karena auth:sanctum

    $favorites = $user->favorites()
        ->with(['category', 'tags'])
        ->orderByDesc('favorites.created_at')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $favorites,
    ], 200);
}

public function store(Request $request, Recipe $recipe)
{
    $user = $request->user();
    $user->favorites()->syncWithoutDetaching([$recipe->id]);

    return response()->json(['message' => 'Favorited']);
}

public function destroy(Request $request, Recipe $recipe)
{
    $request->user()->favorites()->detach($recipe->id);
    return response()->json(['message' => 'Unfavorited']);
}
}
