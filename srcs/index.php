<?php
// Récupération des variables d'environnement définies dans le .env / Docker
$host = "localhost";
$db   = getenv('MYSQL_DATABASE');
$user = getenv('MYSQL_USER');
$pass = getenv('MYSQL_PASSWORD');
$charset = 'utf8mb4';

echo "<h1>Test de Connexion Inception</h1>";

// Test de la version PHP
echo "Version PHP : " . phpversion() . "<br>";

// Tentative de connexion à MySQL via PDO
$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
     $pdo = new PDO($dsn, $user, $pass, $options);
     echo "<h2 style='color:green;'>✅ Connexion à MySQL réussie !</h2>";
     echo "Base de données connectée : <strong>$db</strong>";
} catch (\PDOException $e) {
     echo "<h2 style='color:red;'>❌ Erreur de connexion :</h2>";
     echo $e->getMessage();
}

echo "<hr>";
// Affichage du PHP Info (optionnel)
echo "<h3>Détails du serveur :</h3>";
phpinfo();
?>