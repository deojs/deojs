/**
 * Operation to replace aliases with the full command name.
 * Also accepts custom command names
 */

class ReplaceAliases {
    constructor() {
        this.aliases = {
            ac: "Add-Content",
            clc: "Clear-Content",
            cli: "Clear-Item",
            clv: "Clear-Variable",
            compare: "Compare-Object",
            cvpa: "Convert-Path",
            copy: "Copy-Item",
            cp: "Copy-Item",
            cpi: "Copy-Item",
            epal: "Export-Alias",
            "%": "ForEach-Object",
            foreach: "ForEach-Object",
            gal: "Get-Alias",
            dir: "Get-ChildItem",
            gci: "Get-ChildItem",
            ls: "Get-ChildItem",
            gcm: "Get-Command",
            cat: "Get-Content",
            gc: "Get-Content",
            type: "Get-Content",
            help: "Get-Help",
            man: "Get-Help",
            gi: "Get-Item",
            gl: "Get-Location",
            pwd: "Get-Location",
            gm: "Get-Member",
            gmo: "Get-Module",
            gdr: "Get-PSDrive",
            gv: "Get-Variable",
            group: "Group-Object",
            iex: "Invoke-Expression",
            ipmo: "Import-Module",
            ii: "Invoke-Item",
            measure: "Measure-Object",
            mi: "Move-Item",
            move: "Move-Item",
            mv: "Move-Item",
            nal: "New-Alias",
            ni: "New-Item",
            nmo: "New-Module",
            nv: "New-Variable",
            popd: "Pop-Location",
            pushd: "Push-Location",
            del: "Remove-Item",
            erase: "Remove-Item",
            rd: "Remove-Item",
            ri: "Remove-Item",
            rm: "Remove-Item",
            rmdir: "Remove-Item",
            rmo: "Remove-Module",
            rv: "Remove-Variable",
            ren: "Rename-Item",
            rni: "Rename-Item",
            rvpa: "Resolve-Path",
            select: "Select-Object",
            sal: "Set-Alias",
            sc: "Set-Content",
            si: "Set-Item",
            cd: "Set-Location",
            chdir: "Set-Location",
            sl: "Set-Location",
            set: "Set-Variable",
            sv: "Set-Variable",
            sort: "Sort-Object",
            tee: "Tee-Object",
            "?": "Where-Object",
            where: "Where-Object"
        };

        this.name = "Replace Aliases";
        this.args = [
            {
                name: "Alias Name",
                type: "dropdown",
                default: "All default aliases",
                options: [
                    "All default aliases",
                    "Custom"
                ].concat(Object.keys(this.aliases).sort())
            },
            {
                name: "Custom Alias Name",
                type: "string",
                default: ""
            },
            {
                name: "Custom Full Name",
                type: "string",
                default: ""
            }
        ];
        this.languages = ["powershell"];
        this.inputType = "ast";
        this.outputType = "ast";
        this.progress = false;
    }

    /**
     * Pretty prints a powershell AST - COPIED FROM POWERSHELL.MJS FOR NOW
     *
     * @param {object} ast - The AST to pretty print
     * @returns {string} - Pretty printed code
     */
    prettyPrint(ast) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) {
                return "";
            }
            if (typeof obj === "string") {
                return obj;
            }
            if (Array.isArray(obj)) {
                let out = "";
                for (let i = 0; i < obj.length; i++) {
                    out += recurse(obj[i]);
                }
                return out;
            }
            if (Object.prototype.hasOwnProperty.call(obj, "data")) {
                return recurse(obj.data);
            }

            return "";
        };

        return recurse(ast);
    }

    /**
     * Finds a genericToken token in the data and checks if the
     * string of that token matches an alias.
     *
     * @param {object} data - The data to search and replace in
     * @param {string} aliasName - The alias to replace
     * @param {string} fullName - The full version of the alias
     */
    replaceAlias(data, aliasName, fullName) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) {
                return;
            }
            if (typeof obj === "string") {
                return;
            }
            if (Array.isArray(obj)) {
                for (let i = 0; i < obj.length; i++) {
                    recurse(obj[i]);
                }
                return;
            }
            if (Object.prototype.hasOwnProperty.call(obj, "data")
            && Object.prototype.hasOwnProperty.call(obj, "type")) {
                if (obj.type === "genericToken") {
                    const text = this.prettyPrint(obj.data);
                    if (aliasName === "All default aliases") {
                        if (Object.prototype.hasOwnProperty.call(this.aliases, text)) {
                            obj.data = this.aliases[text];
                        }
                    } else if (text === aliasName) {
                        obj.data = fullName;
                    }
                    return;
                }
                recurse(obj.data);
            }
        }.bind(this);

        recurse(data);
    }

    /**
     * Run function
     *
     * @param {object} input - The input code AST
     * @param {Array} args - The operation arguments
     * @returns {object} - The modified code
     */
    run(input, args) {
        const recurse = function (obj) {
            if (obj === null || obj === undefined) {
                return;
            }
            if (typeof obj === "string") {
                return;
            }
            if (Array.isArray(obj)) {
                for (let i = 0; i < obj.length; i++) {
                    recurse(obj[i]);
                }
                return;
            }
            if (Object.prototype.hasOwnProperty.call(obj, "data")
            && Object.prototype.hasOwnProperty.call(obj, "type")) {
                if (obj.type === "pipeline") {
                    if (args[0] === "All default aliases") {
                        this.replaceAlias(obj.data, args[0], "");
                    } else if (args[0] === "Custom") {
                        this.replaceAlias(obj.data, args[1], args[2]);
                    } else {
                        this.replaceAlias(obj.data, args[0], this.aliases[args[0]]);
                    }
                    return;
                }
                recurse(obj.data);
            }
        }.bind(this);

        recurse(input);

        return input;
    }
}

export default ReplaceAliases;
