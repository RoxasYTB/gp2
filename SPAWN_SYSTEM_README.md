# Système de Spawn Unifié GP2

Ce système fait en sorte que tous les joueurs en multijoueur spawent au même endroit que le lieu de spawn solo.

## Fonctionnement

1. **Capture automatique** : Le système capture automatiquement la position de spawn du premier joueur (joueur solo)
2. **Application aux autres joueurs** : Tous les autres joueurs qui rejoignent la partie sont automatiquement téléportés à cette position
3. **Séparation automatique** : Les joueurs sont légèrement décalés pour éviter qu'ils se chevauchent

## Configuration

Le système peut être configuré via les ConVars suivantes :

### ConVars disponibles

- `gp2_unified_spawn_enabled` (défaut: 1)
  - Active/désactive le système de spawn unifié
  - 0 = désactivé, 1 = activé

- `gp2_unified_spawn_separation` (défaut: 32)
  - Distance de séparation entre les joueurs en unités Hammer

- `gp2_unified_spawn_separation_axis` (défaut: 1)
  - Axe de séparation des joueurs
  - 0 = X, 1 = Y, 2 = Z

- `gp2_unified_spawn_delay` (défaut: 0.1)
  - Délai avant téléportation en secondes

- `gp2_unified_spawn_debug` (défaut: 1)
  - Affiche des messages de debug
  - 0 = désactivé, 1 = activé

### Exemples d'utilisation

```
// Désactiver le système
gp2_unified_spawn_enabled 0

// Changer la distance de séparation à 64 unités
gp2_unified_spawn_separation 64

// Séparer les joueurs sur l'axe X au lieu de Y
gp2_unified_spawn_separation_axis 0

// Désactiver les messages de debug
gp2_unified_spawn_debug 0
```

## Commandes d'administration

### `gp2_show_spawn_position`
Affiche la position de spawn solo actuelle
- Utilisable par tous les joueurs

### `gp2_reset_spawn_position`
Réinitialise la position de spawn solo capturée
- Nécessite les droits d'administrateur
- Utile si vous voulez recapturer une nouvelle position

### `gp2_set_spawn_position`
Définit manuellement la position de spawn à votre position actuelle
- Nécessite les droits d'administrateur
- Utile pour définir précisément où vous voulez que les joueurs spawent

## Installation

Les fichiers sont automatiquement chargés par Garry's Mod depuis le dossier `autorun/`.

Aucune configuration supplémentaire n'est nécessaire - le système fonctionne automatiquement dès le chargement du serveur.

## Dépannage

### Le système ne fonctionne pas
1. Vérifiez que `gp2_unified_spawn_enabled` est à 1
2. Vérifiez les messages de debug avec `gp2_unified_spawn_debug 1`
3. Utilisez `gp2_show_spawn_position` pour voir si une position a été capturée

### Les joueurs se chevauchent
1. Augmentez la valeur de `gp2_unified_spawn_separation`
2. Changez l'axe de séparation avec `gp2_unified_spawn_separation_axis`

### La position de spawn n'est pas bonne
1. Utilisez `gp2_reset_spawn_position` pour recapturer
2. Ou utilisez `gp2_set_spawn_position` pour définir manuellement

## Compatibilité

Ce système est compatible avec :
- Toutes les cartes Portal 2
- Le framework GP2 existant
- Les autres systèmes de spawn personnalisés (peut nécessiter une configuration)

## Notes techniques

- Le système utilise le hook `PlayerSpawn` pour capturer et appliquer les positions
- La position du premier joueur (EntIndex 1) est utilisée comme référence
- Un délai configurable évite les problèmes de timing lors du spawn
- Le système se réinitialise automatiquement lors du changement de carte
