using System;
using System.Collections.Generic;
using Abp.Application.Features;
using Abp.Authorization;
using Abp.Extensions;
using Abp.Json;
using Abp.MultiTenancy;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Business.Solutions.DashboardCustomization.Definitions
{
    public class WidgetDefinitionConverter : JsonConverter<WidgetDefinition>
    {
        public override void WriteJson(JsonWriter writer, WidgetDefinition? value, JsonSerializer serializer)
        {
            if (value == null)
            {
                return;
            }

            writer.WriteStartObject();

            writer.WritePropertyName(nameof(WidgetDefinition.Id));
            writer.WriteValue(value.Id);

            writer.WritePropertyName(nameof(WidgetDefinition.Name));
            writer.WriteValue(value.Name);

            writer.WritePropertyName(nameof(WidgetDefinition.Side));
            writer.WriteValue(value.Side);

            if (value.PermissionDependency != null)
            {
                writer.WritePropertyName(nameof(WidgetDefinition.PermissionDependency));
                writer.WriteValue(JsonSerializationHelper.SerializeWithType(value.PermissionDependency));
            }

            if (value.UsedWidgetFilters != null)
            {
                writer.WritePropertyName(nameof(WidgetDefinition.UsedWidgetFilters));
                writer.WriteValue(JsonSerializationHelper.SerializeWithType(value.UsedWidgetFilters));
            }

            writer.WritePropertyName(nameof(WidgetDefinition.Description));
            writer.WriteValue(value.Description);

            writer.WritePropertyName(nameof(WidgetDefinition.AllowMultipleInstanceInSamePage));
            writer.WriteValue(value.AllowMultipleInstanceInSamePage);

            if (value.FeatureDependency != null)
            {
                writer.WritePropertyName(nameof(WidgetDefinition.FeatureDependency));
                writer.WriteValue(JsonSerializationHelper.SerializeWithType(value.FeatureDependency));
            }

            writer.WriteEndObject();
        }

        public override WidgetDefinition ReadJson(JsonReader reader, Type objectType, WidgetDefinition existingValue,
            bool hasExistingValue,
            JsonSerializer serializer)
        {
            JObject jObject = JObject.Load(reader);


            var id = GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.Id));
            var name = GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.Name));
            var side = GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.Side)).ToEnum<MultiTenancySides>();

            var usedWidgetFiltersString =
                GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.UsedWidgetFilters));
            var usedWidgetFilters = string.IsNullOrEmpty(usedWidgetFiltersString)
                ? null
                : JsonSerializationHelper.DeserializeWithType<List<string>>(usedWidgetFiltersString);

            var description = GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.Description));
            var allowMultipleInstanceInSamePage = bool.Parse(
                GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.AllowMultipleInstanceInSamePage))
            );

            IPermissionDependency permissionDependency = null;
            var permissionDependencyString =
                GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.PermissionDependency));
            if (!string.IsNullOrEmpty(permissionDependencyString))
            {
                permissionDependency =
                    JsonSerializationHelper.DeserializeWithType<IPermissionDependency>(permissionDependencyString);
            }

            IFeatureDependency featureDependency = null;
            var featureDependencyString =
                GetJsonPropertyValueOrNull(jObject, nameof(WidgetDefinition.FeatureDependency));
            if (!string.IsNullOrEmpty(featureDependencyString))
            {
                featureDependency =
                    JsonSerializationHelper.DeserializeWithType<IFeatureDependency>(featureDependencyString);
            }

            var widgetDefinition = new WidgetDefinition(
                id,
                name,
                side,
                usedWidgetFilters,
                permissionDependency,
                description,
                allowMultipleInstanceInSamePage,
                featureDependency
            );
            return widgetDefinition;
        }

        private string GetJsonPropertyValueOrNull(JObject jObject, string propertyName)
        {
            if (jObject[propertyName] == null)
            {
                return null;
            }

            return jObject[propertyName].Value<string>();
        }
    }
}