<?php
    $list =
    Array
    (
        0 => '34.110.251.255:80',
        1 => '167.114.96.27:9300',
        2 => '45.90.164.114:80'
    )
    ;
    $url = 'https://mailet.in';
    foreach($list as $proxy)
    {
        $proxy_string = "tcp://" . $proxy;
        $options = array(
            'http' => array(
                'proxy' => $proxy_string,
                'timeout'=>3
            )
        );
        $context = stream_context_create($options);
        echo "Trying to access page ". $url.
            " using proxy server ".$proxy."... ";
        flush();
        $page = @file_get_contents( $url, false, $context);
        if($page !== false)
        {
            echo "Succeeded!\n";
            break;
        }
        echo "Failed!\n";
    }
    if($page === false)
        echo "It was not possible to fetch the page ".$url.
           " with any of the listed proxy servers.\n";
    else
        echo "The page ".$url." was retrieved with success. "."It has a length of ".strlen($page)." bytes.\n";
?>
