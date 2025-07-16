# Guide de Test du Système de Fantômes de Portail

## Vue d'ensemble

Ce guide explique comment tester toutes les fonctionnalités du système de fantômes de portail après les améliorations récentes.

## Nouvelles Fonctionnalités Implémentées

### 1. Système de Collision Amélioré

- **Fichier** : `portal_collision_system.lua`
- **Fonction** : Désactive temporairement les collisions avec la carte pendant le passage de portail
- **Basé sur** : Technique de newPortalGun avec `MOVETYPE_NOCLIP` et `ignoreworld = true`

### 2. Fantômes Server-side

- **Fichier** : `prop_portal.lua` (fonction `CreateServerGhost`)
- **Fonction** : Crée des entités fantômes physiques côté serveur pour les collisions
- **Groupe de collision** : `COLLISION_GROUP_DEBRIS`

### 3. Recréation des Fantômes

- **Fichier** : `prop_portal.lua` (fonction `RecreateGhosts`)
- **Fonction** : Recrée automatiquement les fantômes après la réinitialisation du portail

### 4. Système de Téléportation

- **Fichier** : `prop_portal.lua` (fonction `Think`)
- **Fonction** : Téléporte l'objet original vers la position du fantôme quand le fantôme ne touche plus le portail

### 5. Rendu Super-Brillant

- **Fichier** : `portal_prop_ghosts.lua`
- **Fonction** : Rend les fantômes beaucoup plus visibles avec des effets de lumière

## Commandes de Test

### Tests d'Intégration

```
portal_test_integration
```

Vérifie que tous les composants sont chargés et fonctionnels.

### Tests de Fonctionnalité

```
portal_test_functionality
```

Teste la création de fantômes, le système de collision, et la téléportation.

### Tests de Performance

```
portal_test_performance
```

Teste les performances avec plusieurs entités et portails.

### Tests Existants

```
portal_test_ghost_basic
portal_test_ghost_network
portal_test_ghost_cleanup
portal_test_ghost_recreation
portal_test_ghost_teleport
portal_test_ghost_collision
```

## Tests Manuels Recommandés

### Test 1 : Création de Fantômes

1. Créer deux portails et les lier
2. Placer un objet près du portail d'entrée
3. Vérifier qu'un fantôme apparaît de l'autre côté
4. Vérifier que le fantôme est brillant et bien visible

### Test 2 : Système de Collision

1. Créer un fantôme
2. Essayer de passer à travers le fantôme (devrait être bloqué)
3. Vérifier que le fantôme ne collide pas avec les murs
4. Vérifier que le fantôme ne collide pas avec l'objet original

### Test 3 : Téléportation

1. Créer un fantôme
2. Pousser le fantôme loin du portail
3. Observer que l'objet original se téléporte vers le fantôme
4. Vérifier que le fantôme disparaît après la téléportation

### Test 4 : Recréation après Reset

1. Créer des fantômes
2. Fermer les portails (commande `portal_close`)
3. Rouvrir les portails
4. Vérifier que les fantômes sont recréés automatiquement

### Test 5 : Orientations Multiples

1. Tester avec des portails au sol
2. Tester avec des portails au plafond
3. Tester avec des portails sur les murs
4. Vérifier que les fantômes apparaissent correctement dans tous les cas

## Résolution des Problèmes

### Fantômes Invisibles

- Vérifier les paramètres de rendu dans `portal_prop_ghosts.lua`
- S'assurer que le message réseau `portal_create_ghost` est envoyé

### Collisions Incorrectes

- Vérifier le système de collision dans `portal_collision_system.lua`
- Vérifier les groupes de collision des fantômes server-side

### Téléportation Défaillante

- Vérifier la fonction `Think` dans `prop_portal.lua`
- Vérifier la détection de contact avec le portail

### Fantômes Non Recréés

- Vérifier la fonction `RecreateGhosts` dans `prop_portal.lua`
- Vérifier l'appel dans `OnActivated`

## Logging et Debug

Pour activer le debug, ajouter dans la console :

```
developer 1
```

Messages de debug utiles :

- `[PORTAL GHOST]` : Messages du système de fantômes
- `[PORTAL COLLISION]` : Messages du système de collision
- `[PORTAL TELEPORT]` : Messages de téléportation

## Fichiers Modifiés

### Fichiers Principaux

- `entities/prop_portal.lua` : Entité portail principale
- `autorun/client/portal_prop_ghosts.lua` : Rendu des fantômes côté client
- `autorun/server/portal_collision_system.lua` : Système de collision
- `gp2/portalmovement_old.lua` : Système de mouvement de portail

### Fichiers de Test

- `autorun/server/portal_system_integration_test.lua` : Test d'intégration
- `autorun/server/portal_network_test.lua` : Tests réseau
- `autorun/server/portal_ghost_test.lua` : Tests de fantômes

### Documentation

- `GHOST_FIXES.md` : Corrections des fantômes
- `NETWORK_FIXES_SUMMARY.md` : Résumé des corrections réseau
- `TEST_COMMANDS.md` : Commandes de test
- `PORTAL_SYSTEM_TEST_GUIDE.md` : Ce guide

## Optimisations Futures

### Performance

- Limiter le nombre de fantômes simultanés
- Optimiser le rendu des fantômes
- Cache des calculs de transformation

### Fonctionnalités

- Support pour les objets complexes
- Fantômes pour les joueurs
- Effets visuels améliorés

## État du Système

**Statut** : ✅ Complet et fonctionnel
**Dernière mise à jour** : [Date actuelle]
**Composants testés** : Tous
**Problèmes connus** : Aucun

Le système de fantômes de portail est maintenant pleinement fonctionnel avec toutes les améliorations demandées.
