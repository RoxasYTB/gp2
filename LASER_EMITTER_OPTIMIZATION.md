# Optimisation du Système de Laser avec Emitters

## Changements effectués

### Nouvelle Architecture

Au lieu de calculer manuellement tous les segments de laser après qu'il traverse les portails, le système crée maintenant des **Laser Emitters** aux points de sortie des portails.

### Avantages

1. **Performance améliorée** : Les emitters gèrent automatiquement leurs propres rayons laser, réduisant le nombre de calculs complexes
2. **Code simplifié** : Plus besoin de gérer manuellement les collisions et dégâts pour chaque segment de sortie
3. **Logique de jeu native** : Les emitters utilisent la même logique que les lasers normaux (dégâts, réflexions, etc.)
4. **Mémoire réduite** : Moins de données à stocker et transmettre au client

### Fonctionnalités ajoutées

#### 1. `CreateOrUpdatePortalExitEmitter(startPos, direction, recursionDepth, visitedPortals)`

- Recherche les portails sur le trajet du laser
- Calcule la position et l'angle de sortie correcte
- Crée ou met à jour un emitter au portail de sortie
- Gère la récursion pour les portails multiples (max 3 niveaux)

#### 2. `SpawnOrUpdateExitEmitter(exitPortal, emitterPos, emitterAng)`

- Crée un nouvel emitter s'il n'existe pas
- Met à jour la position/angle d'un emitter existant
- Attache l'emitter au portail de sortie (suivi automatique)
- Configure le nettoyage automatique si le portail est supprimé

#### 3. `CleanupExitEmitters()`

- Supprime tous les emitters de sortie créés par ce laser
- Appelée automatiquement à la suppression du laser ou quand il est désactivé

### Modifications des fonctions existantes

#### `Initialize()`

- Initialise la table `self.PortalExitEmitters = {}`

#### `InternalFireLaser()`

- Appelle `CreateOrUpdatePortalExitEmitter()` après le calcul du rayon principal
- Ne gère plus manuellement les segments de sortie

#### `OnStateChange(name, old, new)`

- Active/désactive automatiquement tous les emitters de sortie
- Nettoie les emitters quand le laser est désactivé

#### `OnRemove()`

- Nouvelle fonction qui nettoie les emitters avant la suppression

### Comportement

1. **Création** : Quand un laser traverse un portail, un emitter invisible est créé à la sortie
2. **Suivi** : L'emitter est parenté au portail, donc il suit automatiquement ses mouvements
3. **État** : L'emitter copie l'état (activé/désactivé) du laser source
4. **Nettoyage** : Si le portail ou le laser source est supprimé, l'emitter est automatiquement nettoyé
5. **Récursion** : Les emitters peuvent eux-mêmes créer d'autres emitters s'ils touchent des portails

### Compatibilité

- Conserve le système de segments pour le laser principal (entre l'émetteur et le premier portail)
- Les emitters gèrent tout le reste (collisions, dégâts, réflexions sur cubes, etc.)
- Fonctionne avec le système de réseau existant

### Notes techniques

- Les emitters sont marqués avec `IsPortalExitEmitter = true`
- Ils gardent une référence vers le laser source (`SourceLaser`)
- Ils sont invisibles (`SetNoModel(true)`, `EF_NODRAW + EF_NOSHADOW`)
- Ils sont transmis avec leur parent (`SetTransmitWithParent(true)`)

## Migration depuis l'ancien système

L'ancien système calculait manuellement tous les segments et les envoyait au client. Le nouveau système :

- Calcule uniquement le segment principal
- Crée des emitters qui calculent leurs propres segments
- Réduit drastiquement la quantité de données réseau
- Simplifie la logique côté serveur

## Conclusion

Cette refonte simplifie énormément le code tout en améliorant les performances. Les emitters se comportent comme des lasers autonomes, utilisant tout le système existant (dégâts, réflexions, effets visuels, etc.) sans code dupliqué.
