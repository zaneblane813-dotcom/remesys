<?php
interface MailerInterface {
    public function send(array $mail): array;
}
