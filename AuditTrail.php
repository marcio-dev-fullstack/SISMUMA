<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

/**
 * App\Models\AuditTrail
 *
 * Representa um registro na trilha de auditoria imutável do sistema.
 * Cada registro é um "bloco" encadeado criptograficamente ao anterior.
 *
 * IMPORTANTE: A imutabilidade é garantida por um TRIGGER no PostgreSQL.
 * Tentativas de UPDATE ou DELETE nesta tabela resultarão em um erro no banco de dados.
 *
 * @property int $id
 * @property string $entity_type O tipo do modelo associado (ex: 'licenca', 'documento_fiscal').
 * @property int $entity_id O ID do modelo associado.
 * @property int|null $user_id O ID do usuário que executou a ação.
 * @property string $action A ação registrada (ex: 'DOCUMENT_GENERATED').
 * @property string $document_hash O hash SHA-256 do documento relacionado.
 * @property string|null $previous_block_hash O hash do bloco de auditoria anterior.
 * @property string $current_block_hash O hash deste bloco de auditoria.
 * @property \Illuminate\Support\Carbon $created_at O timestamp da criação do registro.
 * @property-read Model|\Eloquent $entity O modelo associado ao registro de auditoria.
 * @property-read User|null $user O usuário que realizou a ação.
 */
class AuditTrail extends Model
{
    use HasFactory;

    /**
     * A tabela de auditoria só possui o timestamp de criação.
     * Definir UPDATED_AT como null informa ao Laravel para não gerenciar esta coluna.
     */
    public const UPDATED_AT = null;

    /**
     * Os atributos que podem ser atribuídos em massa.
     */
    protected $fillable = [
        'entity_type',
        'entity_id',
        'user_id',
        'action',
        'document_hash',
        'previous_block_hash',
        'current_block_hash',
    ];

    /**
     * Define a relação polimórfica para buscar a entidade relacionada (Licenca, DocumentoFiscal, etc.).
     */
    public function entity(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Define a relação para buscar o usuário que executou a ação.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}