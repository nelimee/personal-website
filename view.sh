#!/usr/bin/env bash

function delayedfirefox {
	sleep 1
	firefox localhost:1313
}
delayedfirefox &
hugo --i18n-warnings server
