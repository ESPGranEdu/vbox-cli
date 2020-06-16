// Globals
const script_root = document.location.origin + "/api";  // http://{ actual_domain }/api
const pull_api_ID = setInterval(pull_api, 500);

// Funcs
function pull_api() {
    // Get JSON from the API
    $.getJSON(script_root, data => {
        let vms = [];
        $.each(data, (vm_name, property) => {
            const cpu_cores = property["cpu_cores"];
            const ram_size = property["ram_size"];
            const load_percentage = property["load_percentage"];

            // Update bar content
            // TODO (ESPGranEdu): Animate the progress bar
            vms.push(
                `<tr><th scope="row">${vm_name}</th>` +
                `<td>${cpu_cores}</td>` +
                `<td>${ram_size} MB</td>` +
                `<td>
                    <div class="progress-bar">
                        <div class="progress-bar-value">${load_percentage}%</div>
                        <div class="progress-bar-fill" style="width: ${load_percentage}%"></div>
                    </div>
                </td></tr>`
            );
        });
        // Change the HTML inside "tbody"
        $("tbody").html(vms.join(""));
    });

}


