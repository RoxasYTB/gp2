# Guide des Couleurs des Portails GP2

Ce guide explique comment utiliser le nouveau système de couleurs des portails avec des noms intuitifs.

## Commandes Principales

### Changer les couleurs

- `portal_color1 <couleur>` - Change la couleur du portail 1
- `portal_color2 <couleur>` - Change la couleur du portail 2
- `portal_colors` - Affiche les couleurs actuelles
- `portal_colors_help` - Affiche l'aide complète

### Commandes raccourcies

- `pc1 <couleur>` - Raccourci pour portal_color1
- `pc2 <couleur>` - Raccourci pour portal_color2
- `pcolors` - Raccourci pour portal_colors
- `phelp` - Affiche l'aide avec aperçu coloré (client seulement)

## Couleurs Disponibles

| Numéro | Nom Français | Nom Anglais | Aliases          |
| ------ | ------------ | ----------- | ---------------- |
| 0      | Rouge        | Red         | rouge, red       |
| 1      | Orange       | Orange      | orange           |
| 2      | Jaune        | Yellow      | jaune, yellow    |
| 3      | Vert Lime    | Lime        | lime             |
| 4      | Vert         | Green       | vert, green      |
| 5      | Cyan         | Cyan        | cyan             |
| 6      | Bleu Clair   | Light Blue  | lightblue        |
| 7      | Bleu         | Blue        | bleu, blue       |
| 8      | Bleu Foncé   | Dark Blue   | darkblue         |
| 9      | Magenta      | Magenta     | magenta          |
| 10     | Rose         | Pink        | rose, pink       |
| 11     | Noir         | Black       | noir, black      |
| 12     | Blanc        | White       | blanc, white     |
| 13     | Gris         | Gray        | gris, gray, grey |
| 14     | Gris Foncé   | Dark Gray   | darkgray         |

## Exemples d'utilisation

```
portal_color1 red         // Portail 1 en rouge
portal_color2 orange      // Portail 2 en orange
pc1 green                 // Portail 1 en vert (raccourci)
pc2 blue                  // Portail 2 en bleu (raccourci)
portal_color1 help        // Affiche l'aide
phelp                     // Aide avec aperçu coloré
```

## Aide et Support

- Tapez `portal_color1 help` ou `portal_color2 help` pour voir les couleurs disponibles
- Tapez `phelp` pour voir l'aide avec aperçu coloré dans le chat
- Les noms de couleurs ne sont pas sensibles à la casse
- Vous pouvez utiliser les noms français ou anglais

## Compatibilité

Ce système reste compatible avec l'ancien système numérique :

- `portal_color_1 5` fonctionne toujours (cyan)
- `portal_color1 cyan` fait la même chose mais plus intuitivement

## Fonctions Lua pour les Développeurs

```lua
-- Obtenir le nom d'une couleur
local colorName = GP2_GetPortalColorName(5) -- Retourne "Cyan"

-- Obtenir le numéro d'une couleur
local colorNumber = GP2_GetPortalColorNumber("blue") -- Retourne 7

-- Obtenir la couleur d'affichage
local displayColor = GP2_GetPortalDisplayColor(0) -- Retourne Color(255, 100, 100)
```
