import "bootstrap";
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
     * Creates the HTML for list arrow
     *
     * @returns {HTMLElement} - The arrow and container
     */
    createFunctionArrow() {
        const arrowContainer = document.createElement("div");
        arrowContainer.style.textAlign = "center";

        const arrow = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        arrow.classList.add("bi");
        arrow.classList.add("bi-arrow-down");
        arrow.setAttribute("width", "2em");
        arrow.setAttribute("height", "2em");
        arrow.setAttribute("viewBox", "0 0 16 16");
        arrow.setAttribute("fill", "#777777");

        const firstPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
        firstPath.setAttribute("fill-rule", "evenodd");
        firstPath.setAttribute("d", "M4.646 9.646a.5.5 0 01.708 0L8 12.293l2.646-2.647a.5.5 0 01.708.708l-3 3a.5.5 0 01-.708 0l-3-3a.5.5 0 010-.708z");
        firstPath.setAttribute("clip-rule", "evenodd");

        const secondPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
        secondPath.setAttribute("fill-rule", "evenodd");
        secondPath.setAttribute("d", "M8 2.5a.5.5 0 01.5.5v9a.5.5 0 01-1 0V3a.5.5 0 01.5-.5z");
        secondPath.setAttribute("clip-rule", "evenodd");

        arrow.appendChild(firstPath);
        arrow.appendChild(secondPath);

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
        const opContainer = document.createElement("div");
        const opDetails = this.App.OperationHelper.getOperationDetails(event.item.getAttribute("opname"));
        const opHtml = this.App.OperationHelper.createOperationHtml(opDetails);


        opContainer.innerText = itemElement.innerText;
        itemElement.innerText = "";

        itemElement.appendChild(this.createFunctionArrow());

        opContainer.classList.add("flowItem");
        opContainer.appendChild(opHtml);
        itemElement.appendChild(opContainer);
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
                pull: "clone",
                put: false
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
    }

    /**
     * Setup function for the entire app
     */
    setupUI() {
        this.createSplits();
        this.createSortableLists();
        this.addEventListeners();

        this.App.OperationHelper.populateOperationsList();
    }

    /**
     * Sends the selected input file to the InputHelper
     *
     * @param {Event} event - Input event
     */
    async loadFiles(event) {
        const element = event.target;
        if (element.files.length > 0) {
            document.getElementById("inputFileName").innerText = "loading...";
            document.getElementById("inputFileButton").setAttribute("disabled", true);
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
        if (error) {
            document.getElementById("inputErrorText").innerText = "An error occurred loading the input file. Check the console for more information.";
            document.getElementById("inputErrorAlert").classList.remove("hidden");
            return;
        }

        const file = data.file.file;
        document.getElementById("inputFileName").innerText = file.name;

        const inputFileButton = document.getElementById("inputFileButton");
        inputFileButton.innerText = "Change";
        inputFileButton.removeAttribute("disabled");

        const parsed = await new Promise((resolve, reject) => {
            this.App.AppWorker.postMessage({
                command: "parseInput",
                data: {
                    callbackid: this.App.addAppWorkerCallback(resolve),
                    language: "powershell",
                    encoding: "utf-8"
                }
            });
        });

        const prettyPrinted = await new Promise((resolve, reject) => {
            this.App.AppWorker.postMessage({
                command: "prettyPrint",
                data: {
                    callbackid: this.App.addAppWorkerCallback(resolve),
                    language: "powershell",
                    ast: parsed
                }
            });
        });

        this.App.OutputHelper.updateOutput(prettyPrinted, "powershell");

        const output = await this.App.OutputHelper.getOutput(true);
        document.getElementById("outputArea").innerHTML = output;
    }
}

export default UIHelper;
