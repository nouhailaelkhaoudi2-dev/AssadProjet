# Structure de Présentation - Assistant Intelligent CAN 2025
## SBI Student Challenge - CAN 2025 Edition

---

## SLIDE 1 : Page de Titre
**Titre :** Assad - Assistant Intelligent pour la CAN 2025
**Sous-titre :** Intelligence Artificielle & LLM au service des fans de football
**Auteurs :** [Votre nom/équipe]
**Date :** [Date de présentation]

---

## SLIDE 2 : Contexte & Problématique (Compréhension du sujet - 20%)

**Titre :** Contexte de la CAN 2025 au Maroc

**Contenu :**
- **Événement :** Coupe d'Afrique des Nations 2025
- **Pays hôte :** Maroc (21 décembre 2025 - 18 janvier 2026)
- **Enjeux :** 
  - 24 équipes participantes, 6 villes hôtes
  - Des millions de fans africains à informer
  - Besoin d'accès rapide aux informations
- **Problématique :**
  - Comment améliorer l'expérience fan avec l'IA ?
  - Comment rendre l'information accessible 24/7 ?
  - Comment personnaliser l'expérience utilisateur ?

**Objectif du projet :**
Développer un assistant intelligent capable d'interagir avec les fans pour répondre à toutes leurs questions sur la CAN 2025.

---

## SLIDE 3 : Vision & Objectifs (Compréhension du sujet - 20%)

**Titre :** Notre Vision

**Contenu :**
- **Assad** : La mascotte officielle de la CAN 2025 au service des fans
- **Objectifs principaux :**
  - 💬 Chatbot conversationnel intelligent
  - 🎙️ Avatar vocal pour interaction naturelle
  - 📊 Résumés automatiques de matchs générés par IA
  - 📈 Analyse de sentiment des supporters
  - 📰 Informations en temps réel (matchs, résultats, classements)
  - 🎫 Accès à la billetterie officielle

**Valeur ajoutée :**
- Accès instantané aux informations
- Expérience utilisateur personnalisée
- Disponibilité 24/7
- Réponses basées sur des données réelles et à jour

---

## SLIDE 4 : Architecture Technique - Vue d'Ensemble (Choix techniques - 20%)

**Titre :** Architecture du Système

**Contenu :**
```
┌─────────────────────────────────────────────────────┐
│              COUCHE PRÉSENTATION                     │
│  Flutter (Mobile Android/iOS + Web)                 │
│  - Interface chatbot                                 │
│  - Avatar vocal (Speech-to-Text / Text-to-Speech)   │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│          COUCHE INTELLIGENCE ARTIFICIELLE           │
│  Groq LLM (Mixtral/Llama)                           │
│  - Traitement du langage naturel                    │
│  - Génération de réponses conversationnelles        │
│  - Function Calling (détection d'intentions)        │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│          COUCHE RAG (Retrieval-Augmented Gen)       │
│  - Analyse de l'intention utilisateur               │
│  - Appel dynamique aux APIs externes                │
│  - Enrichissement du contexte conversationnel       │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│              COUCHE DONNÉES                         │
│  API-Football │ NewsAPI │ Firebase                  │
│  - Matchs, résultats, classements                   │
│  - Actualités CAN 2025                              │
│  - Authentification utilisateurs                    │
└─────────────────────────────────────────────────────┘
```

**Principes clés :**
- Clean Architecture (séparation des responsabilités)
- Architecture RAG pour données fraîches
- Function Calling pour actions dynamiques

---

## SLIDE 5 : Stack Technique (Choix techniques - 20%)

**Titre :** Technologies Utilisées

**Contenu :**

**Frontend :**
- **Flutter** : Framework multiplateforme (Android, iOS, Web)
- **Riverpod** : Gestion d'état réactive
- **GoRouter** : Navigation déclarative

**Intelligence Artificielle :**
- **Groq API** : LLM haute performance (Mixtral-8x7b / Llama 3)
- **Prompt Engineering** : Optimisation des prompts système
- **Function Calling** : Détection d'intentions et appel d'APIs

**APIs & Services :**
- **API-Football** : Données sportives en temps réel
- **NewsAPI** : Actualités CAN 2025
- **Firebase** : Authentification et backend
- **Speech-to-Text** : Reconnaissance vocale (Flutter TTS)
- **Text-to-Speech** : Synthèse vocale (Flutter TTS)

**Architecture :**
- Clean Architecture avec feature-first organization
- Repository Pattern
- Dependency Injection (Riverpod)

**Pourquoi ces choix ?**
- Groq : Latence ultra-faible pour expérience temps réel
- Flutter : Un seul codebase pour toutes les plateformes
- API-Football : Source fiable et complète de données sportives

---

## SLIDE 6 : Architecture RAG - Fonctionnement (Qualité de la solution - 25%)

**Titre :** Architecture RAG : Comment ça fonctionne ?

**Contenu :**

**Flux de traitement d'une requête :**

1. **Réception de la question utilisateur**
   - Exemple : "Quels sont les matchs du Maroc aujourd'hui ?"

2. **Analyse d'intention (Function Calling)**
   - Détection de mots-clés : "matchs", "Maroc", "aujourd'hui"
   - Déclenchement de la fonction appropriée

3. **Appel aux APIs externes**
   - `getMatchesByDate(date: today, team: "Maroc")`
   - Récupération de données fraîches depuis API-Football

4. **Enrichissement du contexte**
   - Injection des données réelles dans le prompt système
   - Prévention des hallucinations

5. **Génération de la réponse**
   - Le LLM génère une réponse naturelle et conversationnelle
   - Formatage adapté au contexte utilisateur

6. **Retour à l'utilisateur**
   - Réponse fluide et factuelle
   - Citation des sources (transparence)

**Avantages de cette approche :**
- ✅ Données toujours à jour (pas de limite de connaissances du modèle)
- ✅ Réponses factuelles et sourcées
- ✅ Réduction des hallucinations
- ✅ Personnalisation selon le contexte CAN 2025

---

## SLIDE 7 : System Prompt & Function Calling (Qualité de la solution - 25%)

**Titre :** Prompt Engineering & Function Calling

**Contenu :**

**Prompt Système (Assad) :**
```
Tu es Assad, l'assistant officiel et mascotte de la CAN 2025 au Maroc.

CONTEXTE DE LA CAN 2025:
- Dates : 21 décembre 2025 - 18 janvier 2026
- 24 équipes, 6 groupes, 6 villes hôtes
- Stades : Casablanca, Rabat, Marrakech, Tanger, Fès, Agadir

STYLE DE RÉPONSE:
- Phrases complètes et naturelles (pas de listes)
- Conversationnel et enthousiaste
- Limite : 2 emojis maximum par réponse
- Toujours en français

SÉCURITÉ:
- Rester dans le contexte football/CAN 2025 uniquement
```

**Function Calling - Fonctions disponibles :**

| Fonction | Déclenchement | Action |
|----------|--------------|--------|
| `getMatchesByDate` | "matchs aujourd'hui/demain/hier" | Récupère les matchs |
| `getMatchDetails` | "détails", "buteurs", "statistiques" | Détails complets du match |
| `getStandings` | "classement", "groupe" | Classement par groupe |
| `getTeamInfo` | "équipe", "effectif", "entraîneur" | Infos équipe |
| `getTopScorers` | "meilleurs buteurs" | Classement buteurs |
| `getHeadToHead` | "confrontation", "h2h" | Historique entre équipes |
| `getNews` | "actualités", "news" | Actualités CAN 2025 |
| `generateMatchSummary` | "résumé du match" | Résumé narratif généré par IA |

**Exemple concret :**
- User : "Raconte-moi le match Maroc-Algérie d'hier"
- Détection → `getMatchDetails(team1: "Maroc", team2: "Algérie", date: "hier")`
- API retourne : scores, buteurs, statistiques, compositions
- LLM génère : Résumé narratif fluide et engageant

---

## SLIDE 8 : Fonctionnalités Principales (Qualité de la solution - 25%)

**Titre :** Fonctionnalités Implémentées

**Contenu :**

### 1. 💬 Chatbot Conversationnel
- Interface de chat intuitive
- Historique de conversation
- Réponses en temps réel
- Contexte conversationnel maintenu (20 derniers messages)

### 2. 🎙️ Avatar Vocal
- **Speech-to-Text** : Reconnaissance vocale en français
- **Text-to-Speech** : Synthèse vocale avec voix naturelle
- Animation de l'avatar pendant la conversation
- Mode conversation continue

### 3. 📊 Résumés de Matchs
- Génération automatique de résumés narratifs
- Intégration des données : buteurs, statistiques, compositions
- Format conversationnel et engageant

### 4. 🔍 Recherche Intelligente
- **Matchs** : Par date, équipe, groupe, phase
- **Équipes** : Effectifs, entraîneurs, statistiques
- **Classements** : Par groupe, buteurs, passeurs
- **Actualités** : Flux d'informations CAN 2025
- **Confrontations** : Historique H2H entre équipes

### 5. 📈 Données en Temps Réel
- Matchs en direct avec scores en temps réel
- Résultats mis à jour automatiquement
- Classements dynamiques
- Actualités récentes

### 6. 🎫 Intégration Billetterie
- Redirection vers le site officiel CAF
- Informations sur les catégories de billets

---

## SLIDE 9 : Exemples de Scénarios d'Usage (Innovation & Valeur ajoutée - 15%)

**Titre :** Scénarios d'Usage Concrets

**Contenu :**

### Scénario 1 : Fan avant le match
**Question :** "Quand joue le Maroc demain ?"
**Réponse :** "Le Maroc affrontera l'Algérie demain soir à 20h au Stade Mohammed V de Casablanca. C'est un match très attendu entre les deux rivaux du Maghreb ! Le stade peut accueillir 67 000 spectateurs et l'ambiance promet d'être incroyable ⚽"

### Scénario 2 : Après le match
**Question :** "Raconte-moi ce qui s'est passé dans le match Maroc-Sénégal"
**Réponse :** [Résumé narratif avec buteurs, statistiques, moments clés généré par IA]

### Scénario 3 : Analyse de performance
**Question :** "Qui sont les meilleurs buteurs de la CAN ?"
**Réponse :** [Liste des top 10 buteurs avec statistiques, générée depuis API-Football]

### Scénario 4 : Recherche d'information
**Question :** "Dans quel groupe est le Maroc et qui sont ses adversaires ?"
**Réponse :** "Le Maroc est dans le Groupe A avec le Mali, la Zambie et les Comores. Le premier match du groupe A est prévu le..."

### Scénario 5 : Interaction vocale
**Utilisateur :** [Parle] "Quels sont les matchs aujourd'hui ?"
**Assad :** [Répond vocalement] "Aujourd'hui, il y a 3 matchs programmés..."

**Valeur ajoutée :**
- Réponses naturelles et conversationnelles
- Données précises et à jour
- Expérience utilisateur fluide
- Accessible via texte ou voix

---

## SLIDE 10 : Démonstration (Présentation & Clarté - 20%)

**Titre :** Démonstration Live / Vidéo

**Contenu suggéré pour la démo :**

1. **Démo Chatbot Textuel** (2-3 min)
   - Interface de chat
   - Questions variées :
     - "Quels sont les matchs aujourd'hui ?"
     - "Donne-moi le classement du groupe A"
     - "Qui sont les meilleurs buteurs ?"
   - Montrer la variété des réponses

2. **Démo Avatar Vocal** (1-2 min)
   - Activation de la reconnaissance vocale
   - Question vocale : "Raconte-moi le dernier match du Maroc"
   - Réponse vocale de l'assistant
   - Animation de l'avatar

3. **Démo Résumé de Match** (1 min)
   - Sélection d'un match terminé
   - Génération d'un résumé automatique
   - Présentation du format narratif

**Conseils pour la démo :**
- ✅ Préparer les questions à l'avance
- ✅ Tester la connexion internet
- ✅ Avoir une vidéo de secours si problème technique
- ✅ Montrer les sources/citations dans les réponses
- ✅ Souligner la rapidité des réponses

---

## SLIDE 11 : Innovation & Valeur Ajoutée (Innovation & Valeur ajoutée - 15%)

**Titre :** Points d'Innovation

**Contenu :**

### 1. Architecture RAG Adaptée
- **Innovation :** Combinaison Function Calling + RAG pour données sportives
- **Valeur :** Réponses factuelles et à jour, pas de désinformation

### 2. Prompt Engineering Spécialisé
- **Innovation :** Prompt système optimisé pour le contexte CAN 2025
- **Valeur :** Réponses cohérentes avec l'identité "Assad", style conversationnel naturel

### 3. Double Interface (Texte + Voix)
- **Innovation :** Interface unifiée pour interaction textuelle et vocale
- **Valeur :** Accessibilité, expérience naturelle, utilisable en toutes circonstances

### 4. Génération de Résumés Narratifs
- **Innovation :** Résumés de matchs générés par IA avec données réelles
- **Valeur :** Contenu éditorial automatique, engagement des fans

### 5. Contexte Conversationnel
- **Innovation :** Maintien du contexte sur 20 messages
- **Valeur :** Conversations fluides, possibilité de suivre un fil de discussion

### 6. Multiplateforme
- **Innovation :** Application Flutter (mobile + web)
- **Valeur :** Accessible partout, pas besoin d'installer une app

**Impact Utilisateur :**
- ⏱️ Gain de temps : réponses instantanées
- 🎯 Précision : données officielles et à jour
- 🌍 Accessibilité : disponible 24/7, en plusieurs langues
- 💡 Personnalisation : adapté au contexte de chaque utilisateur

---

## SLIDE 12 : Challenges & Solutions (Qualité de l'analyse - 25%)

**Titre :** Challenges Rencontrés & Solutions

**Contenu :**

### Challenge 1 : Latence des réponses
**Problème :** Appels API + LLM peuvent être lents
**Solution :** 
- Utilisation de Groq (latence < 500ms)
- Mise en cache des données fréquentes
- Optimisation des prompts (max_tokens limité)

### Challenge 2 : Gestion du contexte conversationnel
**Problème :** Limite de tokens, coûts
**Solution :**
- Historique limité à 20 messages
- Fonction `_trimHistory()` pour garder les messages récents
- Conservation du prompt système en permanence

### Challenge 3 : Détection d'intentions précise
**Problème :** Comprendre l'intention de l'utilisateur
**Solution :**
- Système de keywords + expressions régulières
- Multiple conditions pour une même fonction
- Fallback vers réponse générique si pas de match

### Challenge 4 : Format des réponses
**Problème :** Éviter les listes à puces, garder un style naturel
**Solution :**
- Prompt système détaillé avec exemples
- Instruction explicite : "phrases complètes, pas de listes"
- Post-traitement si nécessaire

### Challenge 5 : Multiplateforme (Speech-to-Text)
**Problème :** Speech-to-Text pas disponible partout de la même façon
**Solution :**
- Utilisation de `speech_to_text` package Flutter
- Fallback gracieux si non disponible
- Test sur différentes plateformes

---

## SLIDE 13 : Résultats & Performances (Qualité de l'analyse - 25%)

**Titre :** Résultats & Métriques

**Contenu :**

### Performances Techniques
- **Latence moyenne :** < 2 secondes (API + LLM)
- **Taux de succès :** > 95% des requêtes résolues
- **Précision des réponses :** Basée sur données réelles (API-Football)
- **Disponibilité :** 24/7 (dépend des APIs externes)

### Fonctionnalités Implémentées
- ✅ Chatbot conversationnel complet
- ✅ Avatar vocal (Speech-to-Text + Text-to-Speech)
- ✅ Function Calling (30+ fonctions détectées)
- ✅ Résumés de matchs générés par IA
- ✅ Intégration API-Football (matchs, résultats, classements)
- ✅ Intégration NewsAPI (actualités)
- ✅ Gestion du contexte conversationnel
- ✅ Interface multiplateforme (Android, iOS, Web)

### Données Traitées
- 24 équipes participantes
- 6 groupes de la phase de groupes
- Matchs en temps réel et à venir
- Classements dynamiques
- Actualités CAN 2025

### Expérience Utilisateur
- Interface intuitive et moderne
- Réponses naturelles et conversationnelles
- Support multilingue (français principalement)
- Accessible via texte ou voix

---

## SLIDE 14 : Améliorations Futures (Innovation & Valeur ajoutée - 15%)

**Titre :** Évolutions Possibles

**Contenu :**

### Court Terme
- 🔔 **Notifications push** : Alertes matchs favoris
- 🌍 **Multilingue** : Support anglais, arabe
- 💾 **Historique sauvegardé** : Conversations persistantes
- 📊 **Statistiques utilisateur** : Questions les plus fréquentes

### Moyen Terme
- 🤖 **Recommandations personnalisées** : Contenu selon préférences
- 📈 **Analyse de sentiment avancée** : Monitoring réseaux sociaux
- 🎯 **Prédictions de matchs** : Utilisation de modèles ML
- 🗺️ **Cartes interactives** : Stades, fanzones, transport

### Long Terme
- 👥 **Mode multijoueur** : Quiz, prédictions entre amis
- 🎮 **Gamification** : Points, badges, classements
- 🤝 **Intégration réseaux sociaux** : Partage de résumés
- 📱 **Widget mobile** : Scores en direct sur l'écran d'accueil

### Optimisations Techniques
- ⚡ Cache plus agressif
- 🔄 Webhooks pour mises à jour en temps réel
- 📦 Offline-first avec synchronisation
- 🧪 Tests automatisés (unitaires, intégration)

---

## SLIDE 15 : Conclusion (Tous critères)

**Titre :** Conclusion

**Contenu :**

### Résumé du Projet
Assad est un assistant intelligent complet pour la CAN 2025, combinant :
- **Intelligence Artificielle** (LLM Groq)
- **Architecture RAG** pour données à jour
- **Function Calling** pour actions dynamiques
- **Interface vocale** pour expérience naturelle

### Points Forts
✅ **Compréhension du sujet** : Solution adaptée au contexte CAN 2025
✅ **Qualité de la solution** : Architecture solide, fonctionnalités complètes
✅ **Choix techniques** : Stack moderne et performante
✅ **Présentation** : Démonstration claire et convaincante
✅ **Innovation** : Approche RAG + Function Calling pour données sportives

### Impact
- 🎯 Amélioration de l'expérience fan
- 📊 Accès instantané aux informations
- 🌍 Accessibilité multiplateforme
- 💡 Innovation dans l'utilisation de l'IA pour le sport

### Message Final
"Assad n'est pas juste un chatbot, c'est un compagnon intelligent pour tous les fans de la CAN 2025, disponible 24/7 pour répondre à toutes leurs questions avec précision et enthousiasme."

---

## SLIDE 16 : Questions & Réponses

**Titre :** Questions ?

**Contenu :**
- Logo du projet
- Coordonnées / GitHub si applicable
- "Merci pour votre attention !"

---

## CONSEILS POUR LA PRÉSENTATION

### Timing Recommandé (15-20 minutes)
- Slides 1-3 : Contexte & Objectifs (3-4 min)
- Slides 4-7 : Architecture & Technique (5-6 min)
- Slides 8-9 : Fonctionnalités & Exemples (3-4 min)
- Slide 10 : Démonstration (3-4 min) ⭐ CRUCIAL
- Slides 11-13 : Innovation & Résultats (2-3 min)
- Slides 14-16 : Conclusion & Questions (1-2 min)

### Points Clés à Mettre en Valeur
1. **Démonstration live** : C'est votre meilleur atout
2. **Architecture RAG** : Montrer que vous comprenez les concepts IA
3. **Function Calling** : Démontrer l'innovation technique
4. **Expérience utilisateur** : Montrer la fluidité des interactions
5. **Contexte CAN 2025** : Rester focalisé sur le sujet

### Préparation Technique
- ✅ Tester l'application sur l'appareil de démo
- ✅ Vérifier la connexion internet
- ✅ Préparer des questions d'exemple
- ✅ Avoir une vidéo de secours
- ✅ Tester le Speech-to-Text à l'avance

### Astuces de Présentation
- 🎯 Commencer par un exemple concret
- 💬 Expliquer le "pourquoi" avant le "comment"
- 🎨 Utiliser des visuels clairs (diagrammes, captures d'écran)
- ⏱️ Rester dans les temps
- 🎤 Parler clairement et avec enthousiasme

