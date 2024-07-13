#!/bin/bash

function echo_bold_blue {
    echo -e "\033[1;34m$1\033[0m"
}

if ! command -v node &> /dev/null
then
    echo_bold_blue "Node.js is not installed. Installing Node.js..."
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo_bold_blue "Node.js is already installed."
fi

if ! command -v npm &> /dev/null
then
    echo_bold_blue "npm is not installed. Installing npm..."
    sudo apt-get install -y npm
else
    echo_bold_blue "npm is already installed."
fi

echo_bold_blue "Creating project directory and navigating into it..."
mkdir -p solana_transactions
cd solana_transactions

echo_bold_blue "Initializing a new Node.js project..."
npm init -y

echo_bold_blue "Installing required packages..."
npm install @solana/web3.js chalk bs58

echo_bold_blue "Prompting user for private key..."
read -sp "Enter your solana wallet private key: " privkey
echo

echo_bold_blue "Creating the Node.js script file..."
cat << EOF > sonic.js
const web3 = require("@solana/web3.js");
const chalk = require("chalk");
const bs58 = require("bs58");

const connection = new web3.Connection("https://devnet.sonic.game", 'confirmed');

const privkey = "$privkey";
const from = web3.Keypair.fromSecretKey(bs58.decode(privkey));
const to = web3.Keypair.generate();

function getRandomDelay() {
    return Math.floor(Math.random() * (3000 - 1000 + 1)) + 1000; // Random delay between 1 and 3 seconds
}

function getRandomAmount() {
    return Math.random() * (0.001 - 0.0001) + 0.0001; // Random amount between 0.0001 and 0.001 SOL
}

(async () => {
    const txCount = 100;
    for (let i = 0; i < txCount; i++) {
        const amount = getRandomAmount();
        const transaction = new web3.Transaction().add(
            web3.SystemProgram.transfer({
                fromPubkey: from.publicKey,
                toPubkey: to.publicKey,
                lamports: amount * web3.LAMPORTS_PER_SOL,
            }),
        );

        console.log(chalk.blue(`Sending Tx ${i+1} of ${txCount} with ${amount.toFixed(6)} SOL`));
        
        const signature = await web3.sendAndConfirmTransaction(
            connection,
            transaction,
            [from],
        );
        console.log(chalk.blue('Tx hash ->'), signature);

        const delay = getRandomDelay();
        console.log(chalk.blue(`Waiting for ${(delay / 1000).toFixed(1)} seconds before sending the next transaction...`));
        await new Promise(resolve => setTimeout(resolve, delay));
    }
})();
EOF

echo_bold_blue "Running the Node.js script..."
node sonic.js
