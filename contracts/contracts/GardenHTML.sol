// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library GardenHTML {
    function html(string memory body, string memory title) external pure returns (string memory) {
        string memory html_ = "<html>";
        html_ = string.concat(html_,
            '<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">',
            '<link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns=', unicode"'http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Cstyle%3E text %7B fill: %23000; %7D @media (prefers-color-scheme: dark) %7B text %7B fill: %23fff; %7D %7D %3C/style%3E%3Ctext y='.9em' font-size='90'%3E ⚘ %3C/text%3E%3C/svg%3E%0A", '" />',
            '<title>', title ,'</title></head>',
            "<style>",
            '*, *::before, *::after { box-sizing: border-box; }',
            'html { -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; } html, body { margin: 0; padding: 0; } body { min-height: 100vh } html,body,pre { font-family: "Courier New", "Courier", monospace; font-size: 15px; line-height: 1.3; }',
            'h1,h2,h3 { margin: 0; font-size: inherit; font-style: inherit; font-weight: inherit;}',
            ".c { max-width: 860px; margin: 0 auto; padding: 0 20px; box-sizing: border-box; }",
            ".c.essay { max-width: 620px; }",
            "a { color: inherit; text-decoration: underline; }",
            ".w { position: relative; min-height: 100vh; display: flex; align-items: center; padding: 10em 0; }",
            ".s { width: 100%; max-width: 860px; }",
            ".s:not(.g) a { max-width: 100%; display: inline-block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }",
            ".t { max-width: 100%; overflow-x: auto; margin: 1em 0; }",
            ".i { margin: 0 0 5em; }",
            ".f { position: fixed; bottom: 1em; right: 1.3em; }",
            ".p { position: absolute; bottom: 2rem; left: 50%; transform: translateX(-50%); font-size: 1.4em; }",
            ".field { white-space: pre; margin: 0 auto; max-width: 100%; overflow-x: auto; }",
            ".field a { text-decoration: none; }",
            ".a { overflow: hidden; display: inline-block; max-width: 100%; text-overflow: ellipsis; vertical-align: middle; }"
            "</style>"
        );
        html_ = string.concat(html_, "<body>", body, "</body></html>");
        return html_;
    }
}