import "bootstrap";
import $ from "jquery";
import Split from "split.js";
import "../../css/css.js";
import Sortable from "sortablejs";

class UIHelper {
    constructor(app) {
        this.App = app;
        this.opSplit = null;
        this.ioSplit = null;
    }

    /**
     * Initialise the split panes in the UI
     */
    createSplits() {
        if (this.opSplit !== null) {
            this.opSplit.destroy();
        }
        if (this.ioSplit !== null) {
            this.ioSplit.destroy();
        }

        this.opSplit = Split(["#opPane", "#ioPane"], {
            sizes: [20, 80],
            minSize: 200
        });
        this.ioSplit = Split(["#flowPane", "#outputPane"], {
            sizes: [60, 40],
            minSize: 200,
            direction: "vertical"
        });
    }

    /**
     * Creates the HTML for the view code button for an operation
     *
     * @returns {HTMLElement} - The view code button
     */
    createFunctionViewCodeButton() {
        const viewCodeButton = document.createElement("div");
        viewCodeButton.classList.add("viewCodeButton");

        viewCodeButton.innerHTML = "<svg width=\"1.2em\" height=\"1.2em\" viewBox=\"0 0 16 16\" class=\"bi bi-code\" fill=\"currentColor\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" d=\"M5.854 4.146a.5.5 0 0 1 0 .708L2.707 8l3.147 3.146a.5.5 0 0 1-.708.708l-3.5-3.5a.5.5 0 0 1 0-.708l3.5-3.5a.5.5 0 0 1 .708 0zm4.292 0a.5.5 0 0 0 0 .708L13.293 8l-3.147 3.146a.5.5 0 0 0 .708.708l3.5-3.5a.5.5 0 0 0 0-.708l-3.5-3.5a.5.5 0 0 0-.708 0z\"/></svg>"

        viewCodeButton.setAttribute("data-toggle", "tooltip");
        viewCodeButton.setAttribute("data-placement", "bottom");
        viewCodeButton.setAttribute("title", "View code");

        viewCodeButton.addEventListener("click", this.showViewCodeModal.bind(this));

        $(() => {
            $(viewCodeButton).tooltip();
        });

        return viewCodeButton;
    }

    /**
     * Creates the HTML for list status indicator
     *
     * @returns {HTMLElement} - The status indicator
     */
    createFunctionStatusIcon() {
        const statusContainer = document.createElement("div");
        statusContainer.classList.add("statusIcon");

        this.updateStatusIcon(statusContainer, "waiting", "Operation has not been executed");

        return statusContainer;
    }

    /**
     * Creates the HTML for list arrow
     *
     * @returns {HTMLElement} - The arrow and container
     */
    createFunctionArrow() {
        const arrowContainer = document.createElement("div");
        arrowContainer.style.textAlign = "center";

        const arrow = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        arrow.classList.add("bi");
        arrow.classList.add("bi-chevron-compact-down");
        arrow.setAttribute("width", "1.2em");
        arrow.setAttribute("height", "1.2em");
        arrow.setAttribute("viewBox", "0 0 16 16");
        arrow.setAttribute("fill", "#777777");

        const firstPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
        firstPath.setAttribute("fill-rule", "evenodd");
        firstPath.setAttribute("d", "M1.553 6.776a.5.5 0 0 1 .67-.223L8 9.44l5.776-2.888a.5.5 0 1 1 .448.894l-6 3a.5.5 0 0 1-.448 0l-6-3a.5.5 0 0 1-.223-.67z");

        arrow.appendChild(firstPath);

        arrowContainer.appendChild(arrow);

        return arrowContainer;
    }

    /**
     * Adds the "flowItem" class to a list item when added to the list
     *
     * @param {Event} event - SortableJs onAdd event object
     */
    onFunctionAdded(event) {
        const itemElement = event.item;
        console.log(event);
        const opContainer = document.createElement("div");
        $(() => {
            $(itemElement).tooltip("dispose");
            $(event.clone).tooltip(); // Recreate tooltip on original item
        });
        const opDetails = this.App.OperationHelper.getOperationDetails(event.item.getAttribute("opname"));
        const opHtml = this.App.OperationHelper.createOperationHtml(opDetails);

        const titleElement = document.createElement("span");
        titleElement.innerText = itemElement.innerText;
        opContainer.appendChild(titleElement);
        itemElement.innerText = "";

        itemElement.appendChild(this.createFunctionArrow());

        opContainer.appendChild(this.createFunctionStatusIcon());
        opContainer.appendChild(this.createFunctionViewCodeButton());
        opContainer.classList.add("flowItem");
        opContainer.appendChild(opHtml);
        itemElement.appendChild(opContainer);
    }

    /**
     * Fired when a flow item stops being dragged
     *
     * @param {Event} event - SortableJs onEnd event
     */
    flowElementDragged(event) {
        if (event.to !== event.from) {
            event.item.parentNode.removeChild(event.item);
        }
    }

    /**
     * Initialises the sortable lists and populates the operations list
     */
    createSortableLists() {
        const opListElement = document.getElementById("operationsList");
        const flowListElement = document.getElementById("flowList");

        Sortable.create(opListElement, {
            animation: 200,
            easing: "cubic-bezier(1, 0, 0, 1)",
            sort: false,
            group: {
                name: "operationsGroup",
                pull: "clone"
            },
            delay: 0
        });
        Sortable.create(flowListElement, {
            animation: 200,
            easing: "cubic-bezier(1, 0, 0, 1)",
            group: {
                name: "operationsGroup"
            },
            onAdd: this.onFunctionAdded.bind(this),
            onEnd: this.flowElementDragged.bind(this),
            delay: 0
        });
    }

    /**
     * Adds relevant event listeners to the UI
     */
    addEventListeners() {
        // Input
        document.getElementById("inputFileButton").addEventListener("click", this.openFileClicked.bind(this));
        document.getElementById("inputFileSelector").addEventListener("change", this.loadFiles.bind(this));
        document.getElementById("inputErrorAlertClose").addEventListener("click", this.closeInputErrorAlert.bind(this));
        document.getElementById("inputScanButton").addEventListener("click", this.scanInputClicked.bind(this));

        // Run
        document.getElementById("runFlowButton").addEventListener("click", this.App.OperationHelper.run.bind(this.App.OperationHelper));

        // Operations
        document.getElementById("debugOpsCheckbox").addEventListener("change", this.refreshOperationsList.bind(this));
    }

    /**
     * Setup function for the entire app
     */
    setupUI() {
        this.createSplits();
        this.createSortableLists();
        this.addEventListeners();

        this.refreshOperationsList();
        this.enableTooltips();

        this.updateStatusIcon(document.getElementById("inputStatusIcon"), "waiting", "Input has not been loaded");

        const codeIcon = this.createFunctionViewCodeButton();
        codeIcon.id = "inputViewCodeButton";
        document.getElementById("inputViewCodeButton").replaceWith(codeIcon);
    }

    /**
     * Removes existing operations and re-populates the list
     */
    refreshOperationsList() {
        this.App.OperationHelper.clearOperationsList();
        this.App.OperationHelper.populateOperationsList(document.getElementById("debugOpsCheckbox").checked);
    }

    /**
     *
     */
    enableTooltips() {
        $(() => {
            $("[data-toggle='tooltip']").tooltip();
        });
    }

    /**
     * Sends the selected input file to the InputHelper
     *
     * @param {Event} event - Input event
     */
    async loadFiles(event) {
        const element = event.target;
        if (element.files.length > 0) {
            this.App.OutputHelper.clearOutput();
            this.updateStatusIcon(document.getElementById("inputStatusIcon"), "loading", "Loading input");

            document.getElementById("inputFileName").innerText = "loading...";
            document.getElementById("inputFileButton").setAttribute("disabled", true);
            document.getElementById("inputProgress").style.display = "";
            document.getElementById("inputProgress").firstElementChild.innerText = "Loading (0%)";
            this.App.AppWorker.postMessage({
                command: "loadfile",
                data: element.files[0]
            });
        }
    }

    /**
     * Handles when the open file button is clicked
     */
    openFileClicked() {
        document.getElementById("inputFileSelector").click();
    }

    /**
     * Fires when the input error alert close button is clicked
     */
    closeInputErrorAlert() {
        document.getElementById("inputErrorAlert").classList.add("hidden");
    }

    /**
     * Fires when the scan input button is clicked
     */
    async scanInputClicked() {
        const scanButton = document.getElementById("inputScanButton");
        const buttonText = scanButton.innerText;

        scanButton.disabled = true;
        scanButton.innerText = "Scanning...";

        const scanResults = await new Promise((resolve, reject) => {
            this.App.AppWorker.postMessage({
                command: "scanInput",
                data: {
                    callbackid: this.App.addAppWorkerCallback(resolve)
                }
            });
        });

        const scanStatus = document.getElementById("inputScanStatus");

        if (Object.prototype.hasOwnProperty.call(scanResults, "response_code")) {
            if (scanResults.response_code === 0) {
                scanStatus.style.color = "";
                scanStatus.innerText = "No match";
            } else {
                if (scanResults.positives !== 0) {
                    scanStatus.style.color = "#FF0000";
                } else {
                    scanStatus.style.color = "";
                }
                scanStatus.innerText = `${scanResults.positives}/${scanResults.total} engines detected this file.`;
            }
        } else {
            scanStatus.innerText = "Scan failed. (Check console)";
            scanStatus.style.color = "#FF0000";
        }

        scanButton.innerText = buttonText;
        scanButton.disabled = false;
    }

    /**
     * Fires when the input file finsihes loading (or errors)
     *
     * @param {ArrayBuffer} data - The data sent back by the FileLoader
     * @param {boolean} error - True if an error occurred
     */
    async inputFileLoaded(data, error) {
        this.updateInputProgress(100, 100, "Loading");

        if (error) {
            this.updateStatusIcon(document.getElementById("inputStatusIcon"), "error", "Error loading input");
            document.getElementById("inputErrorText").innerText = "An error occurred loading the input file. Check the console for more information.";
            document.getElementById("inputErrorAlert").classList.remove("hidden");
            document.getElementById("inputProgress").style.display = "none";
            return;
        }

        this.updateStatusIcon(document.getElementById("inputStatusIcon"), "loading", "Processing input");

        const file = data.file.file;
        document.getElementById("inputFileName").innerText = file.name;

        const inputFileButton = document.getElementById("inputFileButton");
        inputFileButton.innerText = "Change";
        inputFileButton.removeAttribute("disabled");

        const hashes = await new Promise((resolve, reject) => {
            this.App.AppWorker.postMessage({
                command: "calculateInputHashes",
                data: {
                    callbackid: this.App.addAppWorkerCallback(resolve)
                }
            });
        });

        const hashList = document.getElementById("inputFileHashes");
        hashList.style.display = "";

        document.getElementById("inputFileMd5").innerText = `MD5: ${hashes.md5}`;
        document.getElementById("inputFileSha1").innerText = `SHA1: ${hashes.sha1}`;
        document.getElementById("inputFileSha256").innerText = `SHA256: ${hashes.sha256}`;

        this.App.OperationHelper.run();

        this.updateStatusIcon(document.getElementById("inputStatusIcon"), "success", "Input finished loading successfully");
        document.getElementById("inputProgress").style.display = "none";
    }

    /**
     * Updates input load progress
     *
     * @param {number} loaded - The number of input chunks loaded
     * @param {number} total - The total number of input chunks
     * @param {string} progressType - The current input task
     */
    updateInputProgress(loaded, total, progressType) {
        const progress = document.getElementById("inputProgress");
        const progressBar = progress.firstElementChild;
        const loadedPercent = Math.round((loaded / total) * 100);

        progressBar.style.width = `${loadedPercent}%`;
        progressBar.innerText = `${progressType} (${loadedPercent}%)`;
    }

    /**
     * Updates a status icon
     *
     * @param {Element} icon - The element to update
     * @param {string} status - The status type (loading|success|error)
     * @param {string} tooltipText - The text to set as the tooltip
     */
    updateStatusIcon(icon, status, tooltipText) {
        icon.classList.remove("text-success");
        icon.classList.remove("text-danger");
        icon.classList.remove("text-secondary");
        icon.classList.remove("text-warning");
        switch (status) {
        case "loading":
            icon.classList.add("text-secondary");
            icon.innerHTML = "<svg width=\"1.2em\" height=\"1.2em\" viewBox=\"0 0 16 16\" class=\"bi bi-dash-circle-fill\" fill=\"currentColor\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" d=\"M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM4.5 7.5a.5.5 0 0 0 0 1h7a.5.5 0 0 0 0-1h-7z\"/></svg>";
            icon.firstElementChild.classList.add("spinner");
            break;
        case "waiting":
            icon.classList.add("text-secondary");
            icon.innerHTML = "<svg width=\"1.2em\" height=\"1.2em\" viewBox=\"0 0 16 16\" class=\"bi bi-dash-circle-fill\" fill=\"currentColor\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" d=\"M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM4.5 7.5a.5.5 0 0 0 0 1h7a.5.5 0 0 0 0-1h-7z\"/></svg>";
            break;
        case "success":
            icon.classList.add("text-success");
            icon.innerHTML = "<svg width=\"1.2em\" height=\"1.2em\" viewBox=\"0 0 16 16\" class=\"bi bi-check-circle-fill\" fill=\"currentColor\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" d=\"M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z\"/></svg>";
            break;
        case "error":
            icon.classList.add("text-danger");
            icon.innerHTML = "<svg width=\"1.2em\" height=\"1.2em\" viewBox=\"0 0 16 16\" class=\"bi bi-x-circle-fill\" fill=\"currentColor\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" d=\"M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM5.354 4.646a.5.5 0 1 0-.708.708L7.293 8l-2.647 2.646a.5.5 0 0 0 .708.708L8 8.707l2.646 2.647a.5.5 0 0 0 .708-.708L8.707 8l2.647-2.646a.5.5 0 0 0-.708-.708L8 7.293 5.354 4.646z\"/></svg>";
            break;
        case "warning":
            icon.classList.add("text-warning");
            icon.innerHTML = "<svg width=\"1.2em\" height=\"1.2em\" viewBox=\"0 0 16 16\" class=\"bi bi-exclamation-circle-fill\" fill=\"currentColor\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" d=\"M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8 4a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 4zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z\"/></svg>";
            break;
        default:
            break;
        }

        if (tooltipText !== null
            && tooltipText !== undefined) {
            icon.setAttribute("data-toggle", "tooltip");
            icon.setAttribute("data-placement", "bottom");
            icon.setAttribute("title", tooltipText);
            $(() => {
                $(icon).tooltip("dispose");
                $(icon).tooltip("enable");
            });
        } else {
            $(() => {
                $(icon).tooltip("dispose");
            });
        }
    }

    /**
     * Displays the view code modal with the selected output code displayed
     *
     * @param {Event} event - The event which triggered the modal
     */
    async showViewCodeModal(event) {
        // Finds the parent flowItem element
        const recurse = function (element) {
            if (element.classList.contains("flowItem")) {
                return element;
            }
            return recurse(element.parentElement);
        };

        const flowItem = recurse(event.target);
        let opNum;
        let opName;

        if (flowItem.id === "inputContainer") {
            opNum = 0;
            opName = "Input";
        } else {
            const liElement = flowItem.parentElement;
            const ulElement = document.getElementById("flowList");
            const elements = Array.from(ulElement.children);

            opNum = elements.indexOf(liElement) + 1;
            opName = flowItem.firstElementChild.innerText;
        }

        const contentElement = document.getElementById("viewCodeModalContent");
        contentElement.firstElementChild.innerText = `View Code - ${opName}`;

        const outputData = await this.App.OutputHelper.getOutput(opNum, true);
        document.getElementById("viewCodeModalArea").innerHTML = outputData.output;

        $("#viewCodeModal").modal();
    }
}

export default UIHelper;
