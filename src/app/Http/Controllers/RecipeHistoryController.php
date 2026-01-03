<?php

namespace App\Http\Controllers;

use App\Models\Recipe;
use Illuminate\Http\Request;
use App\Models\RecipeHistory;
use Illuminate\Support\Carbon;
use App\Http\Controllers\Controller;

class RecipeHistoryController extends Controller
{
    // POST /api/recipes/{recipe}/history
    // Flutter kirim user_id, recipe dari URL
    public function store(Request $request, Recipe $recipe)
    {
        $data = $request->validate([
            'user_id' => ['required','integer','exists:users,id'],
        ]);

        $now = Carbon::now();

        // upsert: kalau sudah ada -> view_count +1, update last_viewed_at
        $history = RecipeHistory::where('user_id', $data['user_id'])
            ->where('recipe_id', $recipe->id)
            ->first();

        if ($history) {
            $history->update([
                'view_count' => $history->view_count + 1,
                'last_viewed_at' => $now,
            ]);
        } else {
            $history = RecipeHistory::create([
                'user_id' => $data['user_id'],
                'recipe_id' => $recipe->id,
                'view_count' => 1,
                'last_viewed_at' => $now,
            ]);
        }

        return response()->json([
            'message' => 'History recorded',
            'data' => $history,
        ], 200);
    }

    // GET /api/users/{user_id}/history
    public function index($user_id)
    {
        $histories = RecipeHistory::query()
            ->where('user_id', $user_id)
            ->with(['recipe.category', 'recipe.tags']) // optional, biar Flutter langsung dapat detail recipe
            ->orderByDesc('last_viewed_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $histories,
        ], 200);
    }

    // DELETE /api/users/{user_id}/history/{recipe_id}  (optional)
    public function destroy($user_id, $recipe_id)
    {
        RecipeHistory::where('user_id', $user_id)
            ->where('recipe_id', $recipe_id)
            ->delete();

        return response()->json(['message' => 'History deleted'], 200);
    }
}
