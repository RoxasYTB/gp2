# Optimisation des Couleurs de Portails GP2

## Vue d'ensemble

Ce système remplace l'ancien système complexe avec des centaines de matériaux de couleurs différents par un système optimisé utilisant seulement 2 matériaux dynamiques et la fonction `SetPortalColor(r, g, b)`.

## Avantages de l'optimisation

1. **Performance améliorée** : Au lieu de charger des centaines de matériaux statiques, seulement 2 matériaux dynamiques sont utilisés
2. **Mémoire réduite** : Réduction significative de l'utilisation de la VRAM
3. **Flexibilité accrue** : Couleurs RGB complètes au lieu d'être limitées aux presets
4. **Code plus simple** : Moins de complexité dans le système de rendu

## Utilisation de base

### Définir la couleur d'un portail

```lua
-- Sur le serveur ou le client
local portal = ents.Create("prop_portal")
portal:SetPortalColor(255, 100, 50) -- Rouge orangé
```

### Obtenir la couleur actuelle

```lua
local color = portal:GetColorVector() -- Retourne Vector(r, g, b)
local color01 = portal:GetColorVector01() -- Retourne Vector(r/255, g/255, b/255)
```

## Commandes de console

### Définir la couleur d'un type de portail

```
portal_set_color <portal_id> <r> <g> <b>
```

Exemples :

```
portal_set_color 1 64 160 255    // Portail bleu (type 1)
portal_set_color 2 255 160 64    // Portail orange (type 2)
```

### Utiliser des presets de couleurs

```
portal_preset_colors <preset_name>
```

Presets disponibles :

- `classic` - Bleu et orange (Portal original)
- `neon` - Cyan et magenta vifs
- `rainbow` - Rouge et vert
- `monochrome` - Blanc et gris

Exemples :

```
portal_preset_colors classic
portal_preset_colors neon
```

## Configuration via ConVars

### Portail Type 1 (Bleu par défaut)

```
portal_color_1_r 64     // Composante rouge (0-255)
portal_color_1_g 160    // Composante verte (0-255)
portal_color_1_b 255    // Composante bleue (0-255)
```

### Portail Type 2 (Orange par défaut)

```
portal_color_2_r 255    // Composante rouge (0-255)
portal_color_2_g 160    // Composante verte (0-255)
portal_color_2_b 64     // Composante bleue (0-255)
```

## Intégration dans le code

### Exemple d'utilisation dans un addon

```lua
-- Créer un portail avec une couleur personnalisée
local function createCustomPortal(pos, ang, portalType, color)
    local portal = ents.Create("prop_portal")
    portal:SetPos(pos)
    portal:SetAngles(ang)
    portal:SetNWInt("Potal:PortalType", portalType)
    portal:Spawn()

    -- Définir la couleur personnalisée
    portal:SetPortalColor(color.r, color.g, color.b)

    return portal
end

-- Utilisation
local redPortal = createCustomPortal(
    Vector(0, 0, 0),
    Angle(0, 0, 0),
    TYPE_BLUE,
    {r = 255, g = 0, b = 0}
)
```

### Mise à jour dynamique des couleurs

```lua
-- Changer la couleur d'un portail existant
local portal = ents.FindByClass("prop_portal")[1]
if IsValid(portal) then
    portal:SetPortalColor(128, 255, 128) -- Vert clair

    -- Forcer la mise à jour du rendu (côté client uniquement)
    if CLIENT then
        portal:UpdateOverlayColor()
    end
end
```

## Migration depuis l'ancien système

L'ancien système utilisait des indices de couleurs complexes avec des variations :

```lua
-- ANCIEN SYSTÈME (à éviter maintenant)
local color_idx = 7  -- Index de couleur
local contrast = 1   // Contraste
local saturation = 0 // Saturation
```

Le nouveau système utilise directement les valeurs RGB :

```lua
-- NOUVEAU SYSTÈME (recommandé)
portal:SetPortalColor(64, 160, 255) -- RGB direct
```

## Optimisations techniques

1. **Matériaux dynamiques** : Seulement 2 matériaux créés au lieu de 135 (15 couleurs × 9 variantes)
2. **Mise à jour en temps réel** : Les couleurs peuvent être changées sans recréer les matériaux
3. **Compatibilité** : Fonctionne avec le système de rendu existant de GP2
4. **Éclairage dynamique** : L'éclairage dynamique utilise automatiquement les couleurs définies

## Résolution de problèmes

### Le portail n'affiche pas la bonne couleur

1. Vérifiez que `SetPortalColor()` est appelé après `Spawn()`
2. Assurez-vous que les valeurs RGB sont entre 0 et 255
3. Sur le client, appelez `portal:UpdateOverlayColor()` si nécessaire

### Performance toujours lente

1. Vérifiez que l'ancien système de matériaux n'est plus chargé
2. Assurez-vous que `portal_borders` est activé si vous voulez voir les effets de couleur
3. Vérifiez les ConVars de performance comme `portal_render`

## Support

Ce système est conçu pour être rétrocompatible avec l'ancien système GP2 tout en offrant de meilleures performances et plus de flexibilité pour les couleurs de portails.
