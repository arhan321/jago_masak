<?php

namespace App\Models;

use App\Models\Recipe;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class RecipeStep extends Model
{
    use HasFactory;

    protected $fillable = [
        'recipe_id',
        'step_number',
        'instruction',
    ];

    protected $casts = [
        'step_number' => 'integer',
    ];

    public function recipe()
    {
        return $this->belongsTo(Recipe::class);
    }
}
