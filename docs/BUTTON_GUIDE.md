# Guide de connexion des boutons GP2

## Types de boutons disponibles

### 1. Boutons piliers (`prop_button`)

- **Modèle par défaut**: `models/props/switch001.mdl`
- **Comportement**: Pression instantanée avec option de délai
- **Outputs**:
  - `OnPressed` : Déclenché quand le bouton est pressé
  - `OnUnPressed` : Déclenché quand le bouton est relâché
  - `OnButtonReset` : Déclenché quand le bouton se remet en place automatiquement
  - `OnButtonPressed` : Alias pour `OnPressed` (compatibilité)
  - `OnButtonUnPressed` : Alias pour `OnUnPressed` (compatibilité)
  - `OnReleased` : Alias pour `OnUnPressed` (compatibilité)

### 2. Boutons souterrains piliers (`prop_under_button`)

- **Modèle par défaut**: `models/props_underground/underground_testchamber_button.mdl`
- **Comportement**: Hérite de `prop_button`
- **Outputs**: Identiques à `prop_button`

### 3. Boutons au sol (`prop_floor_button`)

- **Modèle par défaut**: `models/props/portal_button.mdl`
- **Comportement**: Activé tant qu'une entité valide est dessus
- **Outputs**:
  - `OnPressed` : Déclenché quand une entité entre sur le bouton
  - `OnUnPressed` : Déclenché quand aucune entité n'est plus sur le bouton
  - `OnButtonPressed` : Alias pour `OnPressed` (compatibilité)
  - `OnButtonUnPressed` : Alias pour `OnUnPressed` (compatibilité)
  - `OnReleased` : Alias pour `OnUnPressed` (compatibilité)

### 4. Boutons souterrains au sol (`prop_under_floor_button`)

- **Modèle par défaut**: `models/props_underground/underground_floor_button.mdl`
- **Comportement**: Hérite de `prop_floor_button`
- **Outputs**: Identiques à `prop_floor_button`

## Entités qui peuvent activer les boutons au sol

- `player` : Joueurs
- `prop_weighted_cube` : Cubes lestés
- `prop_monster_box` : Boîtes-monstres

## Inputs disponibles

### Boutons piliers

- `press` : Force l'activation du bouton
- `release` : Force le relâchement du bouton
- `lock` : Verrouille le bouton (ne peut plus être pressé)
- `unlock` : Déverrouille le bouton
- `cancelpress` : Annule la pression actuelle

### Boutons au sol

- `pressin` : Force l'activation du bouton
- `pressout` : Force la désactivation du bouton

## Propriétés importantes

### Boutons piliers

- `Delay` : Délai en secondes avant le relâchement automatique (0 = pas de relâchement automatique)
- `istimer` : Si true, joue des sons de tic-tac quand pressé
- `CheckDistance` : Distance en unités pour la détection automatique de proximité (défaut: 100)

### Boutons au sol

- `skin` : Apparence du bouton (0 = normal, 1 = pressé)
- `model` : Modèle personnalisé du bouton
- `CheckRadius` : Rayon de détection en unités pour la méthode de détection par distance (défaut: 25)

## Dépannage

### Problèmes courants

1. **Le bouton reste activé** :

   - Vérifiez que les événements `OnUnPressed` sont bien connectés
   - Utilisez `gp2_debug_buttons 1` pour activer les logs de débogage
   - Vérifiez qu'aucune entité n'est coincée sur le bouton

2. **Le bouton ne se déclenche pas** :
   - Vérifiez que l'entité peut activer le bouton (joueur, cube lesté, boîte-monstre)
   - Assurez-vous que le bouton n'est pas verrouillé (`unlock` pour les boutons piliers)

### Commandes de débogage (Admin uniquement)

- `gp2_debug_buttons [0/1]` : Active/désactive les logs de débogage des boutons
- `gp2_list_buttons` : Liste tous les boutons actifs avec leur état
- `gp2_release_all_buttons` : Force le relâchement de tous les boutons pressés

## Exemple de connexion dans Hammer

Pour connecter un bouton à une plateforme mobile :

1. **Bouton pilier avec délai de 5 secondes** :

   ```
   OnPressed > func_door > Open
   OnButtonReset > func_door > Close
   ```

2. **Bouton pilier permanent** :

   ```
   Delay: 0
   OnPressed > func_door > Open
   OnUnPressed > func_door > Close
   ```

3. **Bouton au sol** :
   ```
   OnPressed > func_door > Open
   OnUnPressed > func_door > Close
   ```

## Entités compatibles courantes

- `func_door` : Portes
- `func_movelinear` : Plateformes linéaires
- `func_rotating` : Plateformes rotatives
- `env_laser` : Lasers
- `prop_tractor_beam` : Faisceaux de traction
- `logic_relay` : Relais logiques
- `test_button_target` : Entité de test (rouge = inactif, vert = actif)

## Conseils

1. **Utilisation cohérente** : Utilisez toujours `OnPressed`/`OnUnPressed` pour une meilleure lisibilité
2. **Boutons permanents** : Pour les boutons piliers qui restent actifs, mettez `Delay` à 0
3. **Test** : Utilisez l'entité `test_button_target` pour tester vos connexions
4. **Compatibilité** : Les outputs alternatifs (`OnButtonPressed`, `OnReleased`) sont disponibles pour la compatibilité avec d'anciennes cartes
