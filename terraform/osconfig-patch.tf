# --- OS Patch Deployment ---
resource "google_os_config_patch_deployment" "weekly_patch" {
  patch_deployment_id = "${var.resource_prefix}-weekly-patch"

  instance_filter {
    # Target all instances in the zone (could use tags strictly, but prompt asked for "all zones")
    # To target "all zones in us-central1", we use the zone filter logic or tags.
    # Here we filter by zone prefix.
    zones = ["${var.region}-a", "${var.region}-b", "${var.region}-c", "${var.region}-f"]
  }

  patch_config {
    apt {
      type = "DIST" # Dist-upgrade
    }
  }

  recurring_schedule {
    time_zone {
      id = var.patch_schedule_timezone
    }

    time_of_day {
      hours   = var.patch_schedule_hour
      minutes = var.patch_schedule_minute
      seconds = 0
      nanos   = 0
    }

    weekly {
      day_of_week = var.patch_schedule_day
    }
  }
}
