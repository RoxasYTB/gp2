# Portal Visual System - Complete Rendering Optimization

## Vue d'ensemble

Le système de rendu visuel des portails a été complètement remplacé par l'ancien système plus efficace de `old_prop_portal.lua`, avec optimisation des couleurs dynamiques.

## Système de rendu moderne

### Fonctionnalités principales

- **Rendu par stencil** : Performance optimisée avec `render.SetStencil*`
- **Particles dynamiques** : Système de particules intégré avec gestion automatique
- **Ghosting avancé** : Effet fantôme lors du passage dans les portails
- **Couleurs dynamiques** : `SetPortalColor(r,g,b)` sans fichiers matériaux multiples

### Architecture technique

#### Client (cl_init.lua)

- `Draw()` : Rendu principal avec stencil buffer
- `Think()` : Gestion des particules et effets
- `getRenderMesh()` : Génération de la géométrie du portail
- `DrawGhost()` : Effets de ghosting
- Hooks : `RenderScene`, `PostDrawEffects`, `ShouldDrawLocalPlayer`

#### Serveur (init.lua)

- `SetPortalColor(r,g,b)` : Change la couleur dynamiquement
- NetworkVars pour synchronisation client/serveur
- Gestion des effets sonores et fermeture

#### Partagé (shared.lua)

- Définitions des constantes (TYPE_BLUE, TYPE_ORANGE)
- Fonctions de couleur partagées
- SetupDataTables()

## Commandes de console

### portal_set_color

```
portal_set_color <type> <r> <g> <b>
```

- `type` : 1 (bleu) ou 2 (orange)
- `r,g,b` : Valeurs de 0-255

**Exemples** :

- `portal_set_color 1 255 0 0` - Portails bleus en rouge
- `portal_set_color 2 0 255 0` - Portails orange en vert

### portal_preset_colors

```
portal_preset_colors <preset>
```

**Presets disponibles** :

- `classic` - Bleu (0,162,255) / Orange (255,100,0)
- `neon` - Cyan (0,255,255) / Magenta (255,0,255)
- `dark` - Bleu sombre (0,100,150) / Orange sombre (150,50,0)

## Optimisations réalisées

### Performance

- ✅ Remplacement de centaines de matériaux par rendu dynamique
- ✅ Stencil rendering pour performance GPU optimale
- ✅ Gestion intelligente des particules (cleanup automatique)
- ✅ Mesh caching pour réduire les calculs

### Fonctionnalités visuelles

- ✅ Effets de particules complets (ouvre/ferme/ambiant)
- ✅ Ghosting lors du passage dans les portails
- ✅ Support des couleurs personnalisées en temps réel
- ✅ Compatibilité avec les systèmes existants

### Architecture

- ✅ Code modulaire et maintenable
- ✅ NetworkVars pour synchronisation réseau
- ✅ Messages réseau pour effets spéciaux
- ✅ Console commands pour debug et configuration

## Migration depuis l'ancien système

Le nouveau système reprend tous les avantages de l'ancien `old_prop_portal.lua` :

- Rendu stencil natif Source engine
- Gestion complète des effets visuels
- Performance optimisée
- Code plus simple et maintenable

## Développement futur

- Support pour plus de types de portails
- Effets visuels additionnels
- Interface de configuration in-game
- Presets de couleurs étendus

## Code d'exemple

### Créer un portail avec couleur personnalisée

```lua
local portal = ents.Create("prop_portal")
portal:Spawn()
portal:SetPortalColor(128, 255, 0) -- Vert lime
```

### Changer la couleur d'un portail existant

```lua
for _, portal in pairs(ents.FindByClass("prop_portal")) do
    if portal:GetNWInt("Potal:PortalType") == TYPE_BLUE then
        portal:SetPortalColor(255, 0, 128) -- Rose
    end
end
```

### Synchronisation réseau

```lua
-- Le système utilise automatiquement NetworkVars
-- Les changements côté serveur sont automatiquement synchronisés
```
