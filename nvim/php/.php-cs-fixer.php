<?php

return PhpCsFixer\Config::create()
   ->setRiskyAllowed(true)
   ->setRules([
      'echo_tag_syntax' => ['format' => 'short'],
      'require_and_include' => true,
   ])
   ->setFinder(
      PhpCsFixer\Finder::create()
         ->in(getcwd())
   );
