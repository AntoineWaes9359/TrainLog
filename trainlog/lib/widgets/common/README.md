# Widgets Communs

Ce dossier contient les widgets réutilisables de l'application TrainLog.

## InfoCard

Le widget `InfoCard` est un composant réutilisable pour afficher des informations importantes dans un format uniforme et attrayant.

### Utilisation

```dart
import '../widgets/common/info_card.dart';

InfoCard(
  title: 'Titre de l\'information',
  subtitle: 'Information principale',
  description: 'Description optionnelle',
  icon: Icons.info,
  onTap: () {
    // Action optionnelle lors du tap
  },
)
```

### Paramètres

- `title` (String, requis) : Le titre de l'information
- `subtitle` (String, requis) : L'information principale à afficher
- `description` (String?, optionnel) : Description supplémentaire
- `icon` (IconData, requis) : Icône à afficher
- `iconColor` (Color?, optionnel) : Couleur de l'icône (défaut: AppColors.primary)
- `backgroundColor` (Color?, optionnel) : Couleur de fond (défaut: AppColors.primary avec alpha 0.1)
- `borderColor` (Color?, optionnel) : Couleur de la bordure (défaut: AppColors.primary avec alpha 0.3)
- `onTap` (VoidCallback?, optionnel) : Action à exécuter lors du tap

### Exemples d'utilisation

#### Exemple simple
```dart
InfoCard(
  title: 'Prochain trajet',
  subtitle: 'Paris → Lyon',
  description: '14:30 - 16:45',
  icon: Icons.schedule,
)
```

#### Exemple avec couleurs personnalisées
```dart
InfoCard(
  title: 'Distance totale',
  subtitle: '1,250 km',
  description: 'Cumul de tous vos trajets',
  icon: Icons.straighten,
  iconColor: Colors.blue,
  backgroundColor: Colors.blue.withValues(alpha: 0.1),
  borderColor: Colors.blue.withValues(alpha: 0.3),
)
```

#### Exemple avec action
```dart
InfoCard(
  title: 'Gares visitées',
  subtitle: '25 gares',
  description: 'Nombre de gares uniques',
  icon: Icons.train,
  onTap: () {
    // Afficher la liste des gares
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => StationsListScreen(),
    ));
  },
)
```

### Style

Le widget utilise le style de design de l'application avec :
- Police Google Fonts Inter
- Couleurs définies dans `AppColors`
- Bordures arrondies (12px)
- Ombres subtiles
- Espacement cohérent

### Avantages

1. **Cohérence visuelle** : Tous les encarts d'information ont le même style
2. **Réutilisabilité** : Facile à utiliser dans toute l'application
3. **Flexibilité** : Personnalisation des couleurs et actions
4. **Maintenabilité** : Un seul endroit pour modifier le style
5. **Accessibilité** : Support des actions de tap et navigation 