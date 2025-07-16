# Corrections du système de ghost de portails GP2

## Problèmes résolus

### 1. Symétrie axiale incorrecte

- **Problème** : Les ghosts apparaissaient du mauvais côté du portail de sortie
- **Solution** : Remplacement de `WorldToLocal`/`LocalToWorld` par `PortalManager.TransformPortal`
- **Fichier modifié** : `portal_prop_ghosts.lua`

### 2. Transparence des ghosts

- **Problème** : Les ghosts étaient semi-transparents (alpha 120)
- **Solution** : Rendu opaque avec `RENDERMODE_NORMAL` et alpha 255
- **Fichier modifié** : `portal_prop_ghosts.lua`

### 3. Erreurs réseau

- **Problème** : `Broadcast()` au lieu de `net.Broadcast()`
- **Solution** : Correction des appels réseau
- **Fichier modifié** : `prop_portal.lua`

### 4. Doublons de ghosts

- **Problème** : Création de plusieurs ghosts pour le même prop
- **Solution** : Vérification `if not self._portalProps or not self._portalProps[prop]`
- **Fichier modifié** : `prop_portal.lua`

### 5. Détection des portails au sol/plafond

- **Problème** : Système de détection inadapté pour les portails horizontaux
- **Solution** : Détection adaptive basée sur l'orientation du portail
- **Fichier modifié** : `prop_portal.lua`

### 6. Conflits de messages réseau

- **Problème** : `"[gp2] Warning! A net message (GP2_PortalPropGhost) is already started! Discarding in favor of the new message! (SendPortalClose)"`
- **Solution** : Implémentation d'un système de queue pour les messages réseau
- **Fichier modifié** : `prop_portal.lua`

### 7. Interruption des messages lors du fizzle

- **Problème** : Messages réseau interrompus quand un portail fizzle pendant la création de ghosts
- **Solution** : Nettoyage de la queue réseau et utilisation de `net.Abort()` dans `Fizzle()`
- **Fichier modifié** : `prop_portal.lua`

### 8. Fuites mémoire des queues réseau

- **Problème** : Queues réseau non nettoyées lors de la suppression des portails
- **Solution** : Nettoyage de `_netQueue` et `_netProcessing` dans `OnRemove()`
- **Fichier modifié** : `prop_portal.lua`

## Améliorations apportées

### Système de détection adaptive

```lua
-- Déterminer l'orientation du portail
local upDot = math.abs(portalUp:Dot(Vector(0, 0, 1)))
local isFloorCeiling = upDot > 0.8  -- Portail au sol ou au plafond

-- Ajuster la tolérance selon l'orientation
local bboxExpand = isFloorCeiling and 48 or 32
local detectionRadius = isFloorCeiling and 128 or 96
```

### Tolérances adaptatives

- **Portails muraux** : Tolérance normale (32 unités, rayon 96)
- **Portails sol/plafond** : Tolérance élargie (48 unités, rayon 128)
- **Nettoyage adaptatif** : Seuils différents selon l'orientation

### Amélioration du rendu

```lua
-- Rendu opaque au lieu de transparent
ghost:SetRenderMode(RENDERMODE_NORMAL)
ghost:SetColor(Color(255,255,255,255))

-- Amélioration de l'éclairage
ghost:SetSkin(0)
ghost:SetMaterial("")
```

### Système de queue pour les messages réseau

```lua
-- Fonction pour traiter la queue des messages réseau
function ENT:ProcessNetworkQueue()
    if self._netProcessing or #self._netQueue == 0 then return end

    self._netProcessing = true
    local message = table.remove(self._netQueue, 1)

    if message then
        local success = pcall(function()
            net.Start(message.type)
            for _, writeOp in ipairs(message.data) do
                writeOp.func(writeOp.value)
            end
            net.Broadcast()
        end)

        if success and message.callback then
            message.callback()
        end
    end

    self._netProcessing = false
end

-- Ajouter un message à la queue
function ENT:QueueNetworkMessage(msgType, data, callback)
    table.insert(self._netQueue, {
        type = msgType,
        data = data,
        callback = callback
    })

    if not self._netProcessing then
        self:ProcessNetworkQueue()
    end
end
```

### Protection contre les conflits de fizzle

```lua
function ENT:Fizzle()
    -- Vider la queue réseau pour éviter les conflits
    if SERVER then
        self._netQueue = {}
        self._netProcessing = false
        net.Abort()
    end

    net.Start(GP2.Net.SendPortalClose)
        net.WriteVector(self:GetPos())
        net.WriteAngle(self:GetAngles())
        net.WriteVector(self:GetColorVector() * 0.1)
    net.Broadcast()
end
```

## Fichiers modifiés

1. **portal_prop_ghosts.lua** (client)

   - Transformation axiale correcte
   - Rendu opaque
   - Amélioration de l'éclairage

2. **prop_portal.lua** (serveur)
   - Correction des erreurs réseau
   - Détection adaptive des props
   - Protection contre les doublons
   - Système de queue pour les messages réseau
   - Nettoyage des queues réseau lors du fizzle et de la suppression des portails

## Test du système

Un script de test a été créé : `portal_ghost_test.lua`

### Commandes disponibles :

- `gp2_test_ghost_mur` - Crée un portail mural standard
- `gp2_test_ghost_sol` - Crée un portail au sol
- `gp2_test_ghost_plafond` - Crée un portail au plafond
- `gp2_test_ghost_cube` - Spawn un cube près du dernier portail
- `gp2_test_ghost_clean` - Nettoie les entités de test

### Procédure de test :

1. Lancer une carte GP2
2. Utiliser les commandes pour créer différents types de portails
3. Spawner des cubes pour tester la détection
4. Vérifier que les ghosts apparaissent du bon côté avec la bonne opacité

## Nouvelles commandes de test

### Tests de conflits réseau

- `portal_network_test` - Teste les conflits de messages réseau avec fizzle rapide
- `portal_network_stress` - Test de stress avec multiples props et fizzle simultané

### Procédure de test des conflits réseau :

1. Lancer une carte GP2
2. Utiliser `portal_network_test` pour tester le cas de base
3. Utiliser `portal_network_stress` pour tester les cas extrêmes
4. Vérifier l'absence d'erreurs `"A net message is already started"` dans la console

## Transformation mathématique

La transformation axiale correcte utilise :

```lua
-- Symétrie axiale (Y et Z inversés)
editedPos = b:LocalToWorld(Vector(editedPos[1], -editedPos[2], -editedPos[3]))
```

Au lieu de la transformation centrale incorrecte précédente.

## Résultat attendu

- Ghosts opaques et bien éclairés
- Apparition du bon côté du portail de sortie
- Détection améliorée pour tous les types de portails
- Pas d'erreurs réseau
- Pas de doublons de ghosts
- Pas de conflits ou interruptions de messages réseau
- Pas de fuites mémoire des queues réseau
