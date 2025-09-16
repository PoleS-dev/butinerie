<?php
// DÉSACTIVÉ POUR DÉVELOPPEMENT LOCAL
//Begin Really Simple SSL key - DISABLED
// define('RSSSL_KEY', '3hp2s3gwXGs7aH3qlYOSWugmD77u0iKsLhlRa6wiN64SxBL2dewaYmfI8FLeI8eg');
//END Really Simple SSL key

/** DÉSACTIVÉ - Enable W3 Total Cache */
// define('WP_CACHE', true); // Added by W3 Total Cache - DISABLED FOR LOCAL

// FORCER HTTP POUR DÉVELOPPEMENT LOCAL
define('FORCE_SSL_ADMIN', false);

//Begin Really Simple SSL session cookie settings - DISABLED
// @ini_set('session.cookie_httponly', true);
// @ini_set('session.cookie_secure', true);
// @ini_set('session.use_only_cookies', true);
//END Really Simple SSL
/**
 * La configuration de base de votre installation WordPress.
 *
 * Ce fichier est utilisé par le script de création de wp-config.php pendant
 * le processus d’installation. Vous n’avez pas à utiliser le site web, vous
 * pouvez simplement renommer ce fichier en « wp-config.php » et remplir les
 * valeurs.
 *
 * Ce fichier contient les réglages de configuration suivants :
 *
 * Réglages MySQL
 * Préfixe de table
 * Clés secrètes
 * Langue utilisée
 * ABSPATH
 *
 * @link https://fr.wordpress.org/support/article/editing-wp-config-php/.
 *
 * @package WordPress
 */
define( 'DB_NAME',     getenv('DB_NAME') ?: 'wp_db' );
define( 'DB_USER',     getenv('DB_USER') ?: 'wp_user' );
define( 'DB_PASSWORD', getenv('DB_PASS') ?: 'wp_pass' );
define( 'DB_HOST',     'db:3306' ); // pas localhost

define( 'WP_HOME',    getenv('WP_HOME') ?: 'http://localhost:8084' );
define( 'WP_SITEURL', getenv('WP_SITEURL') ?: 'http://localhost:8084' );

/** === Dev options (facultatif) === */
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', true );
@ini_set( 'display_errors', 1 );



define( 'DB_COLLATE', '' );
/**#@+
 * Clés uniques d’authentification et salage.
 *
 * Remplacez les valeurs par défaut par des phrases uniques !
 * Vous pouvez générer des phrases aléatoires en utilisant
 * {@link https://api.wordpress.org/secret-key/1.1/salt/ le service de clés secrètes de WordPress.org}.
 * Vous pouvez modifier ces phrases à n’importe quel moment, afin d’invalider tous les cookies existants.
 * Cela forcera également tous les utilisateurs à se reconnecter.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '*r/h{;P}M/*kGd74$-lLf1716ubwA8P|oYk`={**c&^)|0xp^QRwA7XDHFvZEGy{' );
define( 'SECURE_AUTH_KEY',  ',L/o-wbGM`-?_S?ytBXY8JS/91SQy&T?>I#Z>s8kCcR9sD^[]l>Mp,W{~mdYKD}b' );
define( 'LOGGED_IN_KEY',    '@G]/-?}Uo%;8(7=s-6U*dWQYf%cHNoy2$#I(2AiJut2?_0 l#m9+_a(fg98A{j9T' );
define( 'NONCE_KEY',        '&a-y2`ZRdjN>k:&kKa(#V?<2SPjCO-J.7G8}FF`fp(_Wd_M]:UM>yZ:E1R%*Wq{C' );
define( 'AUTH_SALT',        'U.f%4M?*davhApgu1XPZrFitL[k5N>MZ25LMy/K<}?2pmUgLB=P`iZX`1ru^qa8%' );
define( 'SECURE_AUTH_SALT', 'ma^X|i<]YG=DY~!>zEd#Nd#,} E+L3$g6e99K%&,l`).9,x*g[ByF-~x-`^dUnUl' );
define( 'LOGGED_IN_SALT',   '(Y[!n64;Nz/hmoK+)-zbp|ao;R6Amdz.?elU(%e0gQO>byY:;s~cC%1DA8{/1s1E' );
define( 'NONCE_SALT',       'L!,^[gd 5.+g)}pf&)}B;a7 r[)8-KY-JWmE*~H b[-!akMiCE`G3z(=7rjTu~f@' );
/**#@-*/
/**
 * Préfixe de base de données pour les tables de WordPress.
 *
 * Vous pouvez installer plusieurs WordPress sur une seule base de données
 * si vous leur donnez chacune un préfixe unique.
 * N’utilisez que des chiffres, des lettres non-accentuées, et des caractères soulignés !
 */
$table_prefix = 'wp_';
/**
 * Pour les développeurs : le mode déboguage de WordPress.
 *
 * En passant la valeur suivante à "true", vous activez l’affichage des
 * notifications d’erreurs pendant vos essais.
 * Il est fortemment recommandé que les développeurs d’extensions et
 * de thèmes se servent de WP_DEBUG dans leur environnement de
 * développement.
 *
 * Pour plus d’information sur les autres constantes qui peuvent être utilisées
 * pour le déboguage, rendez-vous sur le Codex.
 *
 * @link https://fr.wordpress.org/support/article/debugging-in-wordpress/
 */

define('WP_ALLOW_REPAIR', true);
/* C’est tout, ne touchez pas à ce qui suit ! Bonne publication. */
/** Chemin absolu vers le dossier de WordPress. */
if ( ! defined( 'ABSPATH' ) )
  define( 'ABSPATH', dirname(__FILE__) . '/' );
/** Réglage des variables de WordPress et de ses fichiers inclus. */
require_once( ABSPATH . 'wp-settings.php' );