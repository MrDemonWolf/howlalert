import type { InputHTMLAttributes } from "react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {}

export function Input({ className = "", ...props }: InputProps) {
	return (
		<input
			className={`w-full rounded-lg border border-navy-lighter bg-navy px-3 py-2 text-sm text-white placeholder-gray-500 focus:border-cyan focus:outline-none focus:ring-1 focus:ring-cyan/50 ${className}`}
			{...props}
		/>
	);
}
