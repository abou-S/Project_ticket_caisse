Backend API - Ticket Scanner & Loyalty System
Ce projet permet aux utilisateurs de scanner leurs tickets de caisse, d'extraire automatiquement les informations via un service OCR, de stocker les détails dans une base SQLite et les fichiers dans MongoDB (via GridFS), et d'attribuer des points de fidélité.
Technologies Utilisées

FastAPI – Framework web asynchrone pour créer l'API REST
Uvicorn – Serveur ASGI pour exécuter FastAPI
SQLAlchemy – ORM pour gérer la base de données SQLite
MongoDB & GridFS – Stockage des fichiers (images/PDF)
Python-Jose – Création et validation des tokens JWT
Passlib[bcrypt] – Hachage sécurisé des mots de passe
python-multipart – Gestion des uploads de fichiers

Structure du Projet
Copy/app
├── main.py                   # Point d'entrée de l'application FastAPI
├── models.py                 # Modèles SQLAlchemy
├── database.py               # Configuration et session de SQLite
├── database_mongo.py         # Connexion à MongoDB (GridFS)
├── auth.py                   # Gestion de l'authentification (inscription, login, JWT)
├── routes/
│   ├── user.py               # Endpoints pour la gestion des utilisateurs
│   ├── ticket.py             # Endpoints pour le traitement des tickets
│   └── brand.py              # Endpoints pour la gestion des marques (optionnel)
├── services/
│   └── ocr.py                # Intégration de l'OCR (extraction d'informations)
└── utils/
    └── helpers.py            # Fonctions utilitaires (ex: parse_currency)
Endpoints Disponibles
1. Endpoints Utilisateur
Inscription

URL: /users/signup
Méthode: POST
Input:
jsonCopy{
  "email": "user@example.com",
  "password": "motdepasse"
}

Output:
jsonCopy{
  "message": "Utilisateur créé avec succès"
}


Connexion

URL: /users/login
Méthode: POST
Input: (OAuth2 form-data)

username (utilisé pour l'e-mail)
password


Exemple (curl):
bashCopycurl -X POST "http://localhost:8000/users/login" \
     -F "username=user@example.com" \
     -F "password=motdepasse"

Output:
jsonCopy{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}


2. Endpoints Ticket
Upload de Ticket

URL: /tickets/upload
Méthode: POST
Input: (Form-data avec fichier file et header Authorization: Bearer <token>)
Exemple (curl):
bashCopycurl -X POST "http://localhost:8000/tickets/upload" \
     -H "Authorization: Bearer <token>" \
     -F "file=@/chemin/vers/ticket.jpg"

Output:
jsonCopy{
  "ticket_id": 1,
  "ocr_data": {
    "store": "U EXPRESS SOULT",
    "date": "18/03/25",
    "location": "127, Boulevard SOULT, PHRIS, 75012",
    "totalPurchase": "8.79 €",
    "products": [
       { "name": "CRÈMERIE L.S.S.", "quantity": "4", "unitPrice": "11 €", "category": "KINI GROSBEL 236MG X10 220G" },
       { "name": "FRAGRANCE A BOIRE", "quantity": "2", "unitPrice": "11 €", "category": "VRAIUR A BOIRE FLOP 055G" },
       { "name": "EPICERIE", "quantity": "1", "unitPrice": "11 €", "category": "NOIX CRUJANT GRALLÉES U 160G" }
    ]
  },
  "points_ajoutes": 10
}


Historique des Tickets

URL: /tickets/history
Méthode: GET
Input: Nécessite un header Authorization: Bearer <token>
Exemple (curl):
bashCopycurl -X GET "http://localhost:8000/tickets/history" \
     -H "Authorization: Bearer <token>"

Output:
jsonCopy{
  "tickets": [
    {
      "ticket_id": 1,
      "mongo_file_id": "605c45e7e4b0a22ef7e9e3a0",
      "donnees_extraites": "{\"store\": \"U EXPRESS SOULT\", ...}",
      "file_hash": "abc123..."
    },
    ...
  ]
}


Récupération du Fichier de Ticket

URL: /tickets/{ticket_id}/file
Méthode: GET
Input: Ticket ID dans l'URL, header Authorization: Bearer <token>
Exemple (curl):
bashCopycurl -X GET "http://localhost:8000/tickets/1/file" \
     -H "Authorization: Bearer <token>" --output ticket.pdf

Output: Fichier en streaming (avec Content-Type adapté, par ex. application/pdf ou image/jpeg)

Validation et Correction Manuelle d'un Ticket

URL: /tickets/{ticket_id}/validate
Méthode: PUT
Input: JSON contenant les corrections (pour le ticket et ses produits)
Exemple:
jsonCopy{
  "store": "Nouveau Magasin",
  "date": "20/03/25",
  "location": "Adresse corrigée",
  "total_purchase": 15.50,
  "donnees_extraites": "{\"store\": \"Nouveau Magasin\", ...}",
  "products": [
      { "id": 3, "name": "Produit Corrigé", "quantity": 2, "unitPrice": 5.75, "category": "categorie" }
  ]
}

Output:
jsonCopy{
  "message": "Ticket validé et corrigé avec succès.",
  "ticket": {
    "id": 1,
    "store": "Nouveau Magasin",
    "date": "20/03/25",
    "location": "Adresse corrigée",
    "total_purchase": 15.50,
    "donnees_extraites": "{\"store\": \"Nouveau Magasin\", ...}",
    "products": [
       {
         "id": 3,
         "name": "Produit Corrigé",
         "quantity": 2,
         "unitPrice": 5.75,
         "category": "categorie"
       }
    ]
  }
}


3. Endpoints Optionnels

Brand & Purchase Management: Endpoints à ajouter pour gérer les marques et les achats, si nécessaire.
Exportation & Statistiques: Pour exporter l'historique des tickets ou afficher des statistiques d'achat.

Stratégie d'Attribution de Points

Points de base: 10 points par ticket
Bonus Achat: 1 point par tranche de 10€ dépensés
Multiplicateur Fidélité: 1.2x si l'utilisateur a scanné au moins 5 tickets
Bonus Catégories Stratégiques: 5 points par unité pour des produits dans des catégories spécifiques (ex: "luxury", "electronics")

Ces règles sont appliquées lors de l'upload du ticket et les points calculés sont ajoutés au total de l'utilisateur.
Installation et Lancement

Installer Python 3.11
bashCopybrew install python@3.11

Créer et activer un environnement virtuel
bashCopy/usr/local/opt/python@3.11/bin/python3.11 -m venv venv
source venv/bin/activate

Installer les dépendances
bashCopypython -m pip install fastapi uvicorn sqlalchemy pymongo 'passlib[bcrypt]' python-jose python-multipart

Lancer l'application
bashCopypython -m uvicorn app.main:app --reload


Conclusion
Ce backend fournit une solution complète pour :

L'inscription et la connexion des utilisateurs
L'upload de tickets avec extraction OCR et stockage dans MongoDB via GridFS
L'attribution de points de fidélité selon une stratégie définie
La consultation de l'historique des tickets et la récupération des fichiers
La validation et correction manuelle des tickets
