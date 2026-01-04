<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class saran extends Model
{
    use HasFactory;
   protected $table = 'sarans';

    protected $fillable = [
        'name',
        'pesan',
    ];
}
