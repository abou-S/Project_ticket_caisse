# Backend API - Ticket Scanner & Loyalty System

Ce projet permet aux utilisateurs de scanner leurs tickets de caisse, d'extraire automatiquement les informations via un service OCR, de stocker les détails dans une base SQLite et les fichiers dans MongoDB (via GridFS), et d'attribuer des points de fidélité.

## Technologies Utilisées

- **FastAPI** – Framework web asynchrone pour créer l’API REST.
- **Uvicorn** – Serveur ASGI pour exécuter FastAPI.
- **SQLAlchemy** – ORM pour gérer la base de données SQLite.
- **MongoDB & GridFS** – Stockage des fichiers (images/PDF).
- **Python-Jose** – Création et validation des tokens JWT.
- **Passlib[bcrypt]** – Hachage sécurisé des mots de passe.
- **python-multipart** – Gestion des uploads de fichiers.

## Structure du Projet

