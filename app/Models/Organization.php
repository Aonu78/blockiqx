<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Organization extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description'];

    public function reports()
    {
        return $this->hasMany(Report::class);
    }

    public function staff()
    {
        return $this->hasMany(Staff::class);
    }
}
