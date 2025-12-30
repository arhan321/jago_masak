<?php

namespace App\Http\Controllers\Api;

use App\Models\Recipe;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()
            ->favorites()
            ->with(['category','tags'])
            ->latest('favorites.created_at')
            ->paginate(10);
    }

    public function store(Request $request, Recipe $recipe)
    {
        $request->user()->favorites()->syncWithoutDetaching([$recipe->id]);
        return response()->json(['message' => 'Favorited']);
    }

    public function destroy(Request $request, Recipe $recipe)
    {
        $request->user()->favorites()->detach($recipe->id);
        return response()->json(['message' => 'Unfavorited']);
    }
}
